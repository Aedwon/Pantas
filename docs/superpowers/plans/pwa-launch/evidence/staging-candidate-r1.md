# Staging candidate r1: client integration merge

Status: working-file conflict resolution complete. Full Flutter suite and static/backend/web checks pass. Android build and native package acceptance remain blocked as detailed below. No staging, commit, fetch, pull, push, deployment, dependency addition, seed rebuild, device operation, or screenshot capture.

## Source and authorization

The October 26 lead brief is the bounded integration plan and conflict ruling. Only this assigned worktree was edited.

- Repository: Aedwon/Pantas, origin https://github.com/Aedwon/Pantas.
- Worktree: /Users/aedwon/Documents/Projects/Pantas-wt-staging-candidate-r1.
- Branch: web/staging-candidate-r1.
- HEAD: 9ae0113ee079d533386424920818e1ce90e11bc2.
- MERGE_HEAD: 5ac7888bd945670e81e73be7bb882a0a151c23f7.
- Existing origin/main policy: 44afc369259e599acdfdc6417d808014e578c1fc, read using git show without fetching.
- Policy: AGENTS.md, WORKFLOW.md and SUBAGENTS.md from that origin/main revision. Read the W2/W4h L2/L3 plans, parallel map, October 5 amendment, B9 plan/evidence, W4h Task 4/W2 Task 9 evidence, current relay-routing and Actions conservation decisions, and local key-access note.
- The explicit brief overrides normal fetch, staging, commit and completion permissions. The lead retains staging, commit and independent acceptance.

## Conflict choices

1. `lib/core/content/bundle/protected_content_installer.dart`: HEAD conditional native/web export. The client version differs from the native implementation only by schema version 10; ported that value into `protected_content_installer_native.dart`. Web continues using the staging server-content bootstrap.
2. `lib/core/ui/components/portable_text_renderer.dart`: deleted, following W2 Task 9. Compared its HEAD implementation and the two ContentRenderer versions. B9 SVG/data-URL/remote/asset loading already exists in ContentRenderer/LessonSvg. The latter is byte-identical between both heads. Kept the client replacement, failure copy, component choices, PNG network path and maxLines support. No staging-only C7 image behavior needed a further port. The staging Markdown IMAGE parser and content fetch hook remain.
3. `test/app/router_paths_preserved_test.dart`: client live routes and retired-route absence checks; `/pro` remains in the expected paths. No `/paywall` resurrection.
4. `test/app/router_redirect_test.dart`: client screen expectations and the HEAD `/pro` checkout-return test preserving all query parameters, including repeated values.
5. `test/core/ui/components/lesson_svg_test.dart`: client ContentRenderer cases, preserving the shared B9 loading, malformed input, palette, PNG/SVG sizing, credits and accessibility coverage.
6. `test/features/metrics/archetypes/archetype_identity_test.dart`: client formatted version, preserving the identical identity rules.
7. `test/features/metrics/archetypes/archetype_templates_test.dart`: client formatted version, preserving the identical template behavior.
8. `test/features/metrics/providers/current_archetype_provider_test.dart`: client version, preserving the additional account-transition ownership tests and removed-archetype fallback cases.

The index still records eight unmerged paths because the brief prohibits git add. Conflict markers are removed from working files; the retired renderer is absent. The lead must stage the reviewed resolutions and deletion.

## Automatic merge review

Computed the requested three-dot diff intersection: 48 paths. The table below records byte comparisons after resolution. For files identical to both heads, no distinct branch behavior can be lost by the merge. Reviewed the distinct merged behavior as follows:

- Settings routes: removed an automatically duplicated `/pro` registration. The remaining redirect preserves the complete URI query and passes checkoutReturnUri into the approved Pro screen. Retired aliases remain absent.
- Storage: preserved staging contentRepository fetchHook and the plain WasmDatabase opener; retained the client's removal of retired quiz-nudge providers.
- ContentRenderer: matches the client. LessonSvg, illustration sources, asset discovery, Markdown seed conversion and seed builder match both heads. Server Markdown IMAGE resolution remains in the staging path.
- Payment provider: matches the client offering/account-refresh and target-exam contracts. The web payment gateway and its tests match both heads, preserving PayMongo behavior.
- Metrics, study-days and roadmap pure Dart sources: match both heads. Shared generated server JS required rebuilding against the combined import closure; the renewed check is recorded below.
- pubspec: kept staging flutter_web_plugins SDK declaration and the client font retirement. Lockfile matches HEAD. No dependency added by this task.
- Content export: preserved HEAD unscoredItems output, needed by the merged schema-10 blueprint model.
- Intersecting tests: identical cases retained; conflict-specific choices are above.

| Path | Matches HEAD | Matches client |
|---|---|---|
| `analysis_options.yaml` | True | True |
| `content/illustrations/sources/pantas.yaml` | True | True |
| `lib/app/routes/settings_routes.dart` | False | True |
| `lib/core/content/bundle/protected_content_installer.dart` | True | False |
| `lib/core/storage/storage.dart` | False | False |
| `lib/core/time/study_days.dart` | True | True |
| `lib/core/ui/components/content_renderer.dart` | False | True |
| `lib/core/ui/components/lesson_svg.dart` | True | True |
| `lib/core/ui/components/portable_text_renderer.dart` | False | True |
| `lib/features/metrics/archetypes/archetype_catalog.dart` | True | True |
| `lib/features/metrics/archetypes/archetype_templates.dart` | True | True |
| `lib/features/metrics/signals/coverage_breadth_signal.dart` | True | True |
| `lib/features/metrics/signals/flag_revisit_signal.dart` | True | True |
| `lib/features/metrics/signals/metric_calculations.dart` | True | True |
| `lib/features/metrics/signals/mock_pacing_signal.dart` | True | True |
| `lib/features/metrics/signals/mock_stamina_signal.dart` | True | True |
| `lib/features/metrics/signals/per_question_speed_signal.dart` | True | True |
| `lib/features/metrics/signals/read_then_quiz_signal.dart` | True | True |
| `lib/features/metrics/signals/retention_shape_signal.dart` | True | True |
| `lib/features/metrics/signals/session_shape_signal.dart` | True | True |
| `lib/features/metrics/signals/subject_affinity_signal.dart` | True | True |
| `lib/features/metrics/signals/test_mode_delta_signal.dart` | True | True |
| `lib/features/metrics/signals/time_of_day_signal.dart` | True | True |
| `lib/features/paywall/application/paywall_providers.dart` | False | True |
| `lib/features/paywall/data/web_payment_gateway.dart` | True | True |
| `lib/features/roadmap/domain/build_roadmap.dart` | True | True |
| `lib/features/roadmap/domain/day_snapshot.dart` | True | True |
| `lib/features/roadmap/domain/week_preview.dart` | True | True |
| `pubspec.lock` | True | False |
| `pubspec.yaml` | False | False |
| `test/app/router_paths_preserved_test.dart` | False | True |
| `test/app/router_redirect_test.dart` | False | False |
| `test/core/time/study_days_test.dart` | True | True |
| `test/core/ui/components/lesson_svg_test.dart` | False | True |
| `test/features/metrics/archetypes/archetype_identity_test.dart` | False | True |
| `test/features/metrics/archetypes/archetype_resolver_test.dart` | True | True |
| `test/features/metrics/archetypes/archetype_templates_test.dart` | False | True |
| `test/features/metrics/providers/current_archetype_provider_test.dart` | False | True |
| `test/features/paywall/data/web_payment_gateway_test.dart` | True | True |
| `test/features/roadmap/domain/build_roadmap_test.dart` | True | True |
| `test/features/roadmap/domain/day_snapshot_test.dart` | True | True |
| `test/features/roadmap/domain/study_days_test.dart` | True | True |
| `test/features/roadmap/domain/week_preview_performance_test.dart` | True | True |
| `test/features/roadmap/domain/week_preview_test.dart` | True | True |
| `tools/build_content_export/build_content_export.dart` | True | False |
| `tools/build_dev_seed/build_dev_seed.dart` | True | True |
| `tools/content/lesson_asset_map.dart` | True | True |
| `tools/content/markdown_portable_text.dart` | True | True |

## Reported failures reproduced before fixes

The focused index test failed with 4 passes and 1 failure: expected 12 entries, actual 15. All three extra indexes are needed: examId/submittedAt for mock eligibility (`functions/src/mockReader.ts` and `mock.ts`), examId/day for study days, and examId/occurredAt for study history (`roadmap.ts`). Preserved all 15 indexes and added exact signatures to the test.

The content-upload suite failed its dry-run fixture with `Invalid lesson illustration path: s/a.md`. The B9 resolver intentionally expects subject/topic/lesson.md to derive the illustration directory. The fixture omitted topic. Changed it to lessons/s/t/a.md, preserving the validator. The focused suite then passed all 17 tests.

First analysis found 30 generated-model errors and one related info because the local generated models were stale after the merge. Ran build_runner; 1956 outputs written. No generated Dart files were edited by hand or staged. Subsequent analysis reports zero issues. The reported nine style infos do not reproduce on the resolved client code. Both metrics tests already have the client's correct formatting. The only initial format finding after resolution was the combined router test; formatted it.

First server build check reported STALE. Rebuilt the tracked server JS from the combined pure Dart sources and repeated --check successfully. The lead must handle this generated output under the brief's staging restrictions.

## Verification output

Logs are retained locally under build/staging-candidate-r1. Final summaries and source identity follow when all requested commands finish.

### Additional integration failure found in the full suite

The first full Flutter run failed `custom_track_repository_test.dart`, "lesson exclusions persist beside topics without a schema change": Expected 25, Actual 26. This test is new on the client (which has AppDatabase schema 25); staging introduced schema 26 and cachedContent. Preserved staging's schema and migration. Updated the stale test expectation to 26. This is a directly caused integration mismatch, not a schema redesign. Renewed full and focused evidence follows.

### Backend execution environment

Port 8080 was occupied by an existing Java process. Preserved that process. During npm test only, temporarily used auth 19099, Firestore 18080, Firestore websocket 19150, storage 19199, hub 14400, logging 14500, UI disabled. The original firebase.json bytes were restored in a finally block after each run.

The first npm test run passed 196 plain tests and 245 emulator tests; the emulator script exited 0. Firebase CLI then exited 2 during shutdown because its config/update checker attempted a write outside the sandbox. Repeated npm test with writable XDG_CONFIG_HOME, NO_UPDATE_NOTIFIER=1 and CI=true. The repeated command exited 0 with the same totals. No dependency or application source changed for this environment correction.

### Initial index failure

```text
                'fields': [
                  {'fieldPath': 'status', 'order': 'ASCENDING'},
                  {'fieldPath': 'retiredAt', 'order': 'ASCENDING'}
                ]
              }
            ]
     Which: has length of <15>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tool/firebase_indexes_layout_test.dart 54:5    main.<fn>
  
00:00 +0 -1: Firebase config declares single-field claims repair overrides
00:00 +1 -1: Firebase config keeps both expiry TTL overrides without indexes
00:00 +2 -1: expiry guard rejects direct and aliased top-level account writes
00:00 +3 -1: source never writes expiry to a top-level account document
00:00 +4 -1: Some tests failed.

Failing tests:
  /Users/aedwon/Documents/Projects/Pantas-wt-staging-candidate-r1/test/tool/firebase_indexes_layout_test.dart: Firebase config declares cleanup and claims repair indexes
```

### Initial upload failure

```text
  lessons/s/a.md: Invalid lesson illustration path: s/a.md
  Nothing written. Fix the sources or pass --skip-invalid.
  
  
  1 !== 0
  
      at TestContext.<anonymous> (file:///Users/aedwon/Documents/Projects/Pantas-wt-staging-candidate-r1/functions/test/content-upload.test.mjs:78:10)
      at Test.runInAsyncScope (node:async_hooks:226:14)
      at Test.run (node:internal/test_runner/test:1402:25)
      at Test.processPendingSubtests (node:internal/test_runner/test:974:18)
      at Test.postRun (node:internal/test_runner/test:1542:19)
      at Test.run (node:internal/test_runner/test:1467:12)
      at async Test.processPendingSubtests (node:internal/test_runner/test:974:7) {
    generatedMessage: false,
    code: 'ERR_ASSERTION',
    actual: 1,
    expected: 0,
    operator: 'strictEqual',
    diff: 'simple'
  }
```

### Fixed upload fixture

```text
✔ index exports the Pro content, mock and ingest callables, all behind App Check (1.169625ms)
✔ a blueprint item is keyed by exam, keeps the sections as JSON and changes version with them (0.400542ms)
✔ a blueprint without a positive duration is refused, so a strict mock never gets a NaN clock (0.208208ms)
✔ a set carries the passages its questions name, and only those (0.218875ms)
✔ a set without passages has no passages key, and a missing passage is refused (0.15375ms)
✔ passage text changes the set version (0.102292ms)
✔ the catalog lists only exams that have content and holds no question or passage text (0.523083ms)
✔ an exam catalog has text-free lessons, compact sets, the passage link and the figure flag (0.174375ms)
✔ a catalog item is versioned by its content and stored as a JSON string (0.214666ms)
✔ an exam catalog over the size limit is split by subject into parts (0.173791ms)
✔ a catalog document that cannot fit under the hard limit is refused (0.060667ms)
✔ every catalog document built from the real content tree is under 1 MiB and holds no text (564.032292ms)
ℹ tests 17
ℹ suites 0
ℹ pass 17
ℹ fail 0
ℹ cancelled 0
ℹ skipped 0
ℹ todo 0
ℹ duration_ms 1309.060166
```

### Analysis after generation

```text
Analyzing 3 items...                                            
No issues found! (ran in 12.1s)
```

### Format

```text
Formatted 1554 files (0 changed) in 4.54 seconds.
```

### Layering

```text
Running build hooks...Running build hooks...check_layering: OK
```

### Attribution

```text
Running build hooks...Running build hooks...check_no_ai_attribution: OK
```

### Server JS rebuild

```text
wrote /Users/aedwon/Documents/Projects/Pantas-wt-staging-candidate-r1/functions/src/generated/pantas_core.js (  174742 bytes,    55133 gzip)
```

### Server JS consistency

```text
generated JS is current
```

### TypeScript

`cd functions && npx tsc --noEmit`: exit 0, no output.

The first full-suite attempt was deliberately interrupted after the schema mismatch was corrected. It is failing-first evidence only, not a completed full-suite result. Flutter printed a shutdown error after interruption. A fresh full suite uses `flutter test --reporter expanded --concurrency=8`; all subsequent Flutter commands run serially. Later input corrections and renewed checks are recorded below.

### Functions final npm test (exit 0)

```text
$ cd functions && npx tsc --noEmit
# exit 0, no output
$ PATH=/opt/homebrew/opt/openjdk@21/bin:$PATH npm test
ℹ tests 196
ℹ suites 0
ℹ pass 196
ℹ fail 0
ℹ cancelled 0
ℹ skipped 0
ℹ todo 0
ℹ duration_ms 3250.571625
ℹ tests 245
ℹ suites 0
ℹ pass 245
ℹ fail 0
ℹ cancelled 0
ℹ skipped 0
ℹ todo 0
ℹ duration_ms 78949.429166
✔  Script exited successfully (code 0)
i  emulators: Shutting down emulators.
```

Environment overrides for the isolated sandbox run are documented above. firebase.json was restored byte-for-byte.

### Duplicate CSE source paths found by renewed full verification

Three CSE blueprint tests failed: unscoredItems expected 15 but was null; totalPublishedItems expected null but was 170/165. Root cause: the merge added older client files `content/mock/cse_pro.yaml` and `cse_sub.yaml` beside staging's approved `cse-pro.yaml` and `cse-sub.yaml`. Both pairs use the same blueprint ids. Sorted export processes underscore filenames last, overwriting the approved hyphenated blueprints when writing the database. The existing client tests correctly require the newer approved counts and topic IDs already in the staging sources. Removed only the two obsolete duplicate files. No counts, approved content, seeds or validators were rewritten. An optional source-restoration question became unnecessary when inspection found the approved sources already present. This is another merge integration defect, resolved under the brief's preservation rule.

### Additional CLI result and Android prerequisite

The completed concurrency-8 Flutter run reported `12:44 +4861 -4: Some tests failed.` Three failures were the CSE duplicates fixed above. The fourth was the package-builder CLI test: invalid release sequence expected exit 64, observed 1. Repeating the exact invalid-sequence command returned 64 with `release sequence must be a positive integer`. A focused Flutter rerun of the CSE blueprint file and CLI test passed all four tests in six seconds. No CLI implementation or expected exit code was changed. Added subprocess stdout/stderr to exit-code assertion reasons so a recurrence reports its actual cause. A fresh default-concurrency full suite now verifies the final input; no concurrency-8 full pass is claimed.

The staging web release build passed. Its font-family warning mentions CupertinoIcons, and the Wasm dry run succeeded. The dev APK build failed because no dev google-services.json exists in this assigned worktree. No Firebase configuration was invented, no other worktree was accessed, and no build requirement was bypassed. Requested the existing config location from the lead; Android remains blocked until that prerequisite arrives.

The next full run exposed two related tests that constructed old underscore filenames dynamically. Updated `task3_mock_blueprints_test.dart` to read the approved hyphenated CSE sources, pin 15/20 unscored items and the absence of totalPublishedItems, reject the two obsolete duplicate paths, retain the Subprofessional uncertainty/provenance assertions, and retain the ACET aptitude placeholder marker assertions. This aligns the earlier Task 3 tests with the later October 19 blueprint contract already enforced by cse_blueprint_test.dart. No source counts or UI changed. The earlier literal-path search missed these dynamic filenames; the failing run caught them.

### Native package compatibility not accepted

The existing copied `assets/seed/content.manifest.json` declares contentSchemaVersion 9 and readerSchemaMin/Max 9. Its payload SHA256 is `0ef89a64f2d2f63854b3d22048a7d992d5c04fb03df4fec2e7f4e898e6d083dc`. The approved client ContentDatabase and native installer require schema 10. This is a declared package/reader mismatch. No protected-package decryption or native startup test was performed, so actual installed payload compatibility is not claimed. Preserved the copied package and signature exactly; no regeneration or staging. The lead must supply the compatible approved package or resolve the native compatibility contract before native acceptance. The web branch uses C7 server content and skips this bundled installer.

The Firebase CLI read-only SDK-config retrieval for the existing dev app also failed (`Failed to get ANDROID app configuration`). No login, app creation or remote mutation was attempted. Android still needs the ignored dev Firebase config.

## Final verification and handoff

Source manifest: 1837 files, SHA256 `561ad5bb83e48183acd2c8b9a2f888363285846e4703c32683bd35933205e8f8`. Non-document working patch against HEAD SHA256 `47c02c891d3dd0180c67450c1f8a86581c6fb0c6a59ec67efc1a8f6e6d2b6afc`. Both retained in build/staging-candidate-r1. Dart 3.12.2 on macos_arm64; installed Flutter 3.44.6.

```text
$ flutter test test/features/mock_exam/data/task3_mock_blueprints_test.dart test/features/mock_exam/cse_blueprint_test.dart test/tool/content_package_builder_cli_test.dart --reporter expanded
00:06 +3: /Users/aedwon/Documents/Projects/Pantas-wt-staging-candidate-r1/test/tool/content_package_builder_cli_test.dart: content package builder is an executable fail-closed CLI
00:06 +4: /Users/aedwon/Documents/Projects/Pantas-wt-staging-candidate-r1/test/tool/content_package_builder_cli_test.dart: content package builder is an executable fail-closed CLI
00:06 +5: /Users/aedwon/Documents/Projects/Pantas-wt-staging-candidate-r1/test/tool/content_package_builder_cli_test.dart: content package builder is an executable fail-closed CLI
00:07 +6: All tests passed!
exit: 0
```

```text
$ flutter test --reporter expanded
07:50 +4859: /Users/aedwon/Documents/Projects/Pantas-wt-staging-candidate-r1/test/features/roadmap/domain/coverage_property_test.dart: following the plan covers everything before review-only days
07:50 +4860: /Users/aedwon/Documents/Projects/Pantas-wt-staging-candidate-r1/test/features/roadmap/domain/coverage_property_test.dart: following the plan covers everything before review-only days
07:50 +4861: /Users/aedwon/Documents/Projects/Pantas-wt-staging-candidate-r1/test/features/roadmap/domain/coverage_property_test.dart: following the plan covers everything before review-only days
07:50 +4862: /Users/aedwon/Documents/Projects/Pantas-wt-staging-candidate-r1/test/features/roadmap/domain/coverage_property_test.dart: following the plan covers everything before review-only days
07:50 +4863: /Users/aedwon/Documents/Projects/Pantas-wt-staging-candidate-r1/test/features/roadmap/domain/coverage_property_test.dart: following the plan covers everything before review-only days
07:50 +4864: /Users/aedwon/Documents/Projects/Pantas-wt-staging-candidate-r1/test/features/roadmap/domain/coverage_property_test.dart: following the plan covers everything before review-only days
09:47 +4865: All tests passed!
exit: 0
```

```text
$ flutter analyze lib test tool
Analyzing 3 items...                                            
No issues found! (ran in 8.9s)
exit: 0
```

```text
$ dart format --output=none --set-exit-if-changed lib test tool
Formatted 1554 files (0 changed) in 1.64 seconds.
exit: 0
```

```text
$ dart run tool/check_layering.dart
Running build hooks...Running build hooks...check_layering: OK
exit: 0
```

```text
$ dart run tool/check_no_ai_attribution.dart
Running build hooks...Running build hooks...check_no_ai_attribution: OK
exit: 0
```

The renewed backend run after duplicate content removal exited 0:

```text
$ cd functions && PATH=/opt/homebrew/opt/openjdk@21/bin:$PATH npm test
ℹ tests 196
ℹ suites 0
ℹ pass 196
ℹ fail 0
ℹ cancelled 0
ℹ skipped 0
ℹ todo 0
ℹ duration_ms 5065.28325
ℹ tests 245
ℹ suites 0
ℹ pass 245
ℹ fail 0
ℹ cancelled 0
ℹ skipped 0
ℹ todo 0
ℹ duration_ms 90526.47625
✔  Script exited successfully (code 0)
exit: 0
```

### Server consistency

```text
$ server_dart/build.sh --check
generated JS is current
```

### Web release build

```text
$ flutter build web --release -t lib/main_staging.dart
Compiling lib/main_staging.dart for the Web...                  
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Expected to find fonts for (MaterialIcons, Phosphor, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons, Phosphor). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 9264 bytes (99.4% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Font asset "Phosphor.ttf" was tree-shaken, reducing it from 488636 to 13660 bytes (97.2% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib/main_staging.dart for the Web...                     35.8s
✓ Built build/web
```

### Dev APK build

```text
$ flutter build apk --debug --flavor dev -t lib/main_dev.dart
Running Gradle task 'assembleDevDebug'...                       
Caught exception: Could not start the FSEvents stream: /opt/homebrew/share/flutter/packages/flutter_tools/gradle

FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':app:processDevDebugGoogleServices'.
> File google-services.json is missing. 
  The Google Services Plugin cannot function without it. 
  Searched locations: /Users/aedwon/Documents/Projects/Pantas-wt-staging-candidate-r1/android/app/src/dev/debug/google-services.json, /Users/aedwon/Documents/Projects/Pantas-wt-staging-candidate-r1/android/app/src/debug/dev/google-services.json, /Users/aedwon/Documents/Projects/Pantas-wt-staging-candidate-r1/android/app/src/dev/google-services.json, /Users/aedwon/Documents/Projects/Pantas-wt-staging-candidate-r1/android/app/src/debug/google-services.json, /Users/aedwon/Documents/Projects/Pantas-wt-staging-candidate-r1/android/app/src/devDebug/google-services.json, /Users/aedwon/Documents/Projects/Pantas-wt-staging-candidate-r1/android/app/google-services.json

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 25s
Running Gradle task 'assembleDevDebug'...                          26.3s
Gradle task assembleDevDebug failed with exit code 1
```

### Remaining limits

- No staging, commit, merge continuation, push or deployment. HEAD and MERGE_HEAD remain the assigned SHAs. The Git index still reports eight unmerged paths until the lead stages the reviewed working-file resolutions.
- Dev APK build: blocked by missing ignored dev google-services.json. No build bypass or invented configuration.
- Native startup/package compatibility: copied package manifest declares schema 9; native reader/installer require 10. Pinned package unchanged. No package rebuild, decryption, device test or native startup acceptance.
- Web build succeeds with the CupertinoIcons font-family warning preserved above. No visual acceptance or live PWA/deployment check claimed.
- Independent lead acceptance remains separate from this implementation evidence.
- Generated Dart outputs and server JS were not staged. The lead must respect the brief's generated-file restrictions when preparing the commit. Seed files were neither regenerated nor staged.

### Final git status --short

The status includes all pre-existing automatic merge results, not only edits made in this task.

```text
D  assets/fonts/OFL-SourceSans3.txt
D  assets/fonts/OFL-SourceSerif4.txt
D  assets/fonts/SourceSans3-Bold.ttf
D  assets/fonts/SourceSans3-Regular.ttf
D  assets/fonts/SourceSans3-SemiBold.ttf
D  assets/fonts/SourceSerif4-Regular.ttf
D  assets/fonts/SourceSerif4-Semibold.ttf
A  content/mock/acet.yaml
AD content/mock/cse_pro.yaml
AD content/mock/cse_sub.yaml
A  docs/content/lesson-svg-authoring.md
A  docs/design/proposals/w4b-web-trial-notice-2026-10-24-v1.html
A  docs/design/proposals/w4e-cse-finale-2026-10-21-v1.html
A  docs/superpowers/plans/2026-10-21-w4e-cse-finale.md
A  docs/superpowers/plans/2026-10-21-w4e-server-client.md
A  docs/superpowers/plans/new-design/evidence/W4a.md
M  docs/superpowers/plans/new-design/evidence/W4b.md
M  docs/superpowers/plans/new-design/evidence/W4c.md
M  docs/superpowers/plans/new-design/evidence/W4d.md
M  docs/superpowers/plans/new-design/evidence/W4e.md
A  docs/superpowers/plans/new-design/evidence/W4f.md
A  docs/superpowers/plans/new-design/evidence/W4h-task4-W2-task9.md
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-correction-analysis-final.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-correction-analysis-final.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-correction-analysis-renewed.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-correction-analysis-renewed.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-correction-gates-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-correction-gates-0.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-correction-gates-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-correction-renewed-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-correction-renewed-0.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-correction-renewed-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-custom-green.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-custom-picker-green.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-custom-prefs-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-custom-prefs-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-custom-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-custom-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-final-static-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-final-static-0.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-final-static-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-final-static-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-final-static-3.txt
R  lib/features/auth_flow/data/.gitkeep -> docs/superpowers/plans/new-design/evidence/logs/W4d-audit-final-static-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-flagged-green.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-flagged-ui-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-flagged-ui-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-quick-existing-final.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-quick-existing-renewed.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-quick-existing-renewed.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-quick-first-green.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-quick-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-quick-resume.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-ui-disposal-green-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-ui-disposal-green-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-ui-disposal-green-1.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-ui-disposal-red-both.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-ui-disposal-red-both.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-ui-disposal-red-real.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-ui-disposal-red-real.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-ui-disposal-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-ui-disposal-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-ui-final-static-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-ui-final-static-0.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-ui-final-static-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-ui-final-static-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-audit-ui-final-static-3.txt
R  lib/features/auth_flow/domain/.gitkeep -> docs/superpowers/plans/new-design/evidence/logs/W4d-audit-ui-final-static-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-baseline-flutter-test.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-baseline-source-manifest.json.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-baseline-status.json.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-combined-first-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-combined-first-0.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-combined-first-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-combined-generation.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-combined-renewed-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-combined-renewed-0.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-combined-renewed-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-combined-static-final-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-combined-static-final-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-combined-static-final-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-combined-static-final-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-combined-static-final-3.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-editor-renewed.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-final-flutter-test.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-final-source-manifest.json.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-final-status.json.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-checkpoint-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-checkpoint-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-checkpoint-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-checkpoint-2.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-checkpoint-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-checkpoint-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-checkpoint-5.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-checkpoint-5.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-checkpoint-manifest.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-content-error-check.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-content-error-check.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-disposal-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-disposal-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-final-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-final-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-final-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-final-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-final-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-final-5.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-final-6.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-final-6.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-launch-boundary-final-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-launch-boundary-final-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-launch-boundary-final-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-launch-boundary-final-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-launch-boundary-final-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-launch-boundary-final-4.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-launch-boundary-green-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-launch-boundary-green-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-launch-boundary-green-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-launch-boundary-green-2.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-launch-boundary-manifest.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-launch-boundary-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-launch-boundary-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-launch-boundary-save-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-launch-boundary-save-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-launch-boundary-save-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-launch-boundary-save-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-launch-boundary-save-3.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-launch-boundary-save-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-launch-boundary-save-5.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-launch-boundary-save-6.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-launch-boundary-save-6.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-navigation-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-navigation-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-rebuild-green-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-rebuild-green-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-rebuild-green-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-rebuild-green-2.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-scope-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-scope-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-scoped-navigation-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-scoped-navigation-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-start-missing-green-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-start-missing-green-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-start-missing-green-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-start-missing-green-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-start-missing-green-3.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-start-missing-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-flagged-start-missing-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-interrupted-flutter-test.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-interrupted-interrupted-for-review.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-interrupted-source-manifest.json.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-neutral-dependency-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-neutral-dependency-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-neutral-dependency-2.txt
R  lib/features/auth_flow/presentation/.gitkeep -> docs/superpowers/plans/new-design/evidence/logs/W4d-neutral-dependency-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-neutral-dependency-manifest.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-rich-row-final-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-rich-row-final-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-rich-row-final-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-rich-row-final-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-rich-row-final-3.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-rich-row-green-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-rich-row-green-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-rich-row-green-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-rich-row-green-2.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-rich-row-manifest.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-rich-row-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-stale-next-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-stale-next-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-tab-truthful-green-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-tab-truthful-green-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-tab-truthful-green-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-tab-truthful-manifest.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-tab-truthful-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-tab-truthful-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task2-check-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task2-check-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task2-cleanup-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task2-cleanup-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task2-corrected-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task2-corrected-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task2-corrected-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task2-corrected-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task2-corrected-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task2-final-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task2-final-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task2-final-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task2-final-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task2-final-4.txt
R  lib/features/progress/data/.gitkeep -> docs/superpowers/plans/new-design/evidence/logs/W4d-task2-final-5.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task2-final-6.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task2-final-7.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task2-lintfix-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task2-lintfix-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task2-lintfix-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task2-paused-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task2-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task2-source-identity.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-adjust-prefs-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZE_Long-outline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZE_Long-outline.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZE_Long-timeline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZE_Many-outline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZE_Many-outline.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZE_Many-timeline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZE_ManyTime-outline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZE_ManyTime-outline.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZE_ManyTime-timeline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZE_None-outline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZE_None-outline.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZE_None-timeline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZE_One-outline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZE_One-outline.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZE_One-timeline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZE_RunsShort-outline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZE_RunsShort-outline.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZE_RunsShort-timeline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZE_Short-outline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZE_Short-outline.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZE_Short-timeline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZS_1-outline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZS_1-outline.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZS_1-timeline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZS_1b-outline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZS_1b-outline.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZS_1b-timeline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZS_1c-outline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZS_1c-outline.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZS_1c-timeline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZS_1d-outline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZS_1d-outline.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZS_1d-timeline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZ_Picker-outline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZ_Picker-outline.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-QZ_Picker-timeline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-board-identity.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-budget-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-clarification-green-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-clarification-green-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-clarification-green-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-clarification-green-2.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-clarification-red-matching.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-clarification-red-rules.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-clarification-red-ui.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-commands.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-core-final-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-core-final-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-core-final-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-core-final-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-core-final-4.txt
R  lib/features/progress/domain/.gitkeep -> docs/superpowers/plans/new-design/evidence/logs/W4d-task3-core-final-5.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-core-final-commands.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-core-final-identity.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-core-green.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-current-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-current-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-current-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-current-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-current-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-current-5.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-current-5.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-current-6.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-current-7.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-current-8.txt
R  lib/features/progress/presentation/.gitkeep -> docs/superpowers/plans/new-design/evidence/logs/W4d-task3-current-9.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-current-commands.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-current-identity.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-final-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-final-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-final-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-final-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-final-4.txt
R  lib/features/review/data/.gitkeep -> docs/superpowers/plans/new-design/evidence/logs/W4d-task3-final-5.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-helpers-green.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-lintfix-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-lintfix-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-lintfix-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-log-normalization.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-mechanical-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-mechanical-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-mechanical-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-motion-green-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-motion-green-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-motion-green-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-motion-green-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-motion-green-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-motion-green-5.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-motion-green-6.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-motion-green-7.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-motion-green-8.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-motion-green-9.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-motion-green-9.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-motion-real-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-motion-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-order-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-page-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-recency-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-refresh-loaded-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-refresh-real-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-refresh-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-resume-identity.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-rule6-final-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-rule6-final-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-rule6-final-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-rule6-final-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-rule6-final-3.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-rule6-final-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-rule6-final-5.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-rule6-final-6.txt
R  lib/features/review/domain/.gitkeep -> docs/superpowers/plans/new-design/evidence/logs/W4d-task3-rule6-final-7.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-rule6-final-commands.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-rule6-green-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-rule6-green-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-rule6-green-1.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-rule6-green-commands.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-rule6-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-rule6-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-rules-green.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-rules-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-save-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-save-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-save-10.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-save-11.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-save-12.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-save-13.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-save-13.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-save-14.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-save-15.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-save-16.txt
R  lib/features/review/presentation/.gitkeep -> docs/superpowers/plans/new-design/evidence/logs/W4d-task3-save-17.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-save-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-save-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-save-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-save-5.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-save-6.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-save-7.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-save-8.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-save-9.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-save-commands.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-save-identity.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-save-style-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-save-style-0.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-save-style-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-save-style-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-save-style-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-save-style-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-save-style-commands.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-save-style-identity.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-scope-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-screen-pace-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-selected-tab-commands.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-selected-tab-final-identity.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-selected-tab-green-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-selected-tab-green-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-selected-tab-green-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-selected-tab-green-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-selected-tab-green-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-selected-tab-green-4.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-selected-tab-green-5.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-selected-tab-green-6.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-selected-tab-green-7.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-selected-tab-green-8.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-selected-tab-identity.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-selected-tab-manifest.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-selected-tab-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-selected-tab-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-selected-tab-style-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-selected-tab-style-0.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-selected-tab-style-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-selected-tab-style-commands.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-shared-states-final-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-shared-states-final-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-shared-states-final-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-shared-states-final-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-shared-states-final-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-shared-states-final-4.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-shared-states-final-commands.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-shared-states-green-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-shared-states-green-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-shared-states-green-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-shared-states-green-2.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-shared-states-green-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-shared-states-green-3.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-shared-states-green-commands.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-shared-states-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-shared-states-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-source-identity.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-target-green-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-target-green-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-target-green-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-target-green-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-target-green-3.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-target-green-commands.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-target-invalidators-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-target-invalidators-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-toggle-drift-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-toggle-drift-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-access-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-access-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-access-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-access-2.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-board-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-board-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-board-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-board-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-board-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-board-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-checkpoint-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-checkpoint-0.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-checkpoint-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-checkpoint-1.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-checkpoint-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-checkpoint-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-checkpoint-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-checkpoint-5.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-checkpoint-6.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-checkpoint-7.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-checkpoint-8.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-checkpoint-commands.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-checkpoint-identity.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-checkpoint-manifest.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-complete-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-complete-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-complete-1.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-complete-commands.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-complete-identity.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-contract-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-empty-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-empty-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-empty-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-empty-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-empty-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-empty-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-final-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-final-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-final-10.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-final-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-final-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-final-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-final-5.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-final-6.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-final-6.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-final-7.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-final-8.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-final-9.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-final-commands.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-final-identity.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-first-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-first-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-guard-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-guard-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-guard-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-guard-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-guard-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-guard-5.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-guard-5.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-guard-6.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-guard-7.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-guard-8.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-guard-9.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-guard-commands.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-guard-identity.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-hours-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-hours-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-hours-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-hours-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-hours-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-hours-5.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-hours-5.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-large-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-large-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-large-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-large-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-large-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-large-5.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-large-5.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-material-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-material-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-material-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-material-2.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-retry-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-sizing-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-sizing-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-sizing-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-sizing-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-sizing-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-sizing-4.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-syntax-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-syntax-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-syntax-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-syntax-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-syntax-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-syntax-5.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-target-final-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-target-final-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-target-final-1.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-target-final-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-target-final-2.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-target-final-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-target-final-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-target-final-5.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-target-final-6.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-target-final-6.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-target-final-commands.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-target-final-identity.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task3-ui-zero-pace-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-affected-draft-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-affected-draft-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-affected-draft-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-affected-draft-2.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-affected-draft-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-affected-draft-3.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-analysis-final.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-analysis-final.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_Answer-outline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_Answer-outline.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_Answer-timeline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_Figure-outline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_Figure-outline.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_Figure-timeline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_Flag-outline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_Flag-outline.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_Flag-timeline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_Grid-outline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_Grid-outline.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_Grid-timeline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_GridBack-outline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_GridBack-outline.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_GridBack-timeline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_GridMock-outline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_GridMock-outline.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_GridMock-timeline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_Last-outline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_Last-outline.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_Last-timeline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_Leave-outline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_Leave-outline.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_Leave-timeline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_Long-outline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_Long-outline.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_Long-timeline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_MissFree-outline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_MissFree-outline.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_MissFree-timeline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_MissPro-outline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_MissPro-outline.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-QV_MissPro-timeline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-board-identity.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-checkpoint-manifest.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-compact-revisit-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-compact-revisit-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-core-checkpoint-manifest.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-core-final-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-core-final-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-core-final-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-core-final-2.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-core-final-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-core-final-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-core-final-4.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-core-final-5.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-core-final-5.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-core-final-6.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-core-final-commands.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-core-final-identity.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-core-resume-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-core-resume-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-core-resume-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-core-resume-2.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-core-resume-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-core-resume-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-core-resume-4.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-core-resume-5.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-core-resume-5.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-core-resume-6.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-core-resume-commands.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-core-resume-identity.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-core-style-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-core-style-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-core-style-commands.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-disabled-label-green-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-disabled-label-green-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-disabled-label-green-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-disabled-label-green-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-disabled-label-green-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-disabled-label-green-5.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-disabled-label-green-6.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-disabled-label-green-7.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-disabled-label-green-8.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-disabled-label-green-8.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-disabled-label-green-commands.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-disabled-label-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-disposed-check-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-disposed-check-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-drawn-states-check.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-final-check-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-final-check-0.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-final-check-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-final-check-1.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-final-check-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-final-check-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-final-check-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-final-check-5.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-final-check-5.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-final-check-commands.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-final-material-inputs.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-final-repo-style.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-final-source-identity.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-final-test-style.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-finish-retry-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-finish-retry-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-flag-retry-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-grid-flag-green-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-grid-flag-green-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-grid-flag-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-grid-flag-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-grid-style-final.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-passage-retry-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-passage-retry-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-pick-check-green-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-pick-check-green-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-pick-check-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-post-style-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-post-style-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-post-style-1.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-post-style-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-post-style-2.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-post-style-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-post-style-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-post-style-5.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-post-style-6.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-post-style-6.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-post-style-commands.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-resume-analysis.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-resume-analysis.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-resume-compact-green.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-resume-compact-green.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-resume-compact-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-resume-format-owned.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-resume-recovery-green.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-resume-style-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-resume-style-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-resume-style-10.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-resume-style-11.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-resume-style-12.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-resume-style-13.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-resume-style-14.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-resume-style-15.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-resume-style-16.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-resume-style-17.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-resume-style-18.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-resume-style-19.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-resume-style-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-resume-style-20.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-resume-style-21.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-resume-style-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-resume-style-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-resume-style-5.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-resume-style-6.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-resume-style-7.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-resume-style-8.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-resume-style-9.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-resume-style-commands.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-resume-ui-checks.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-review-analysis-draft.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-review-analysis-draft.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-review-audit-green.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-review-audit-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-review-audit-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-review-batch-boundaries-green-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-review-batch-boundaries-green.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-review-batch-boundaries-green.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-review-batch-boundaries-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-review-batch-boundaries-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-review-batch-green-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-review-batch-green-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-review-batch-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-review-codegen.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-review-completion-initial-guard-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-review-completion-initial-guard-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-review-completion-order-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-review-completion-order-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-review-discard-owner-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-review-discard-owner-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-review-final.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-review-green-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-review-malformed-discard-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-review-malformed-discard-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-review-position-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-review-resume-invalidation-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-review-resume-invalidation-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-review-scope-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-review-signedout-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-review-signedout-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-revisit-flag-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-revisit-flag-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-route-pro-bounded-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-route-pro-bounded-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-route-pro-final-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-route-pro-final-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-route-pro-final-1.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-route-pro-green-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-route-pro-green-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-route-pro-green-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-route-pro-green-2.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-route-pro-manifest.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-route-pro-saved-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-route-pro-saved-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-route-pro-saved-1.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-route-pro-saved-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-route-pro-saved-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-route-pro-saved-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-save-source-identity.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-screen-clean-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-screen-clean-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-screen-clean-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-screen-clean-2.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-screen-green-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-screen-green-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-screen-legacy-fix.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-screen-legacy-fix.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-screen-legacy-green-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-screen-legacy-green-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-screen-legacy-green-1.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-screen-real-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-screen-real-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-screen-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-source-review.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-style-final-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-style-final-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-style-final-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-style-final-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-style-final-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-style-final-commands.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-clean-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-clean-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-clean-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-clean-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-clean-3.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-clean-commands.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-final-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-final-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-final-1.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-final-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-final-2.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-final-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-final-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-final-4.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-final-5.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-final-5.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-final-6.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-final-6.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-final-commands.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-final-identity.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-style-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-style-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-style-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-style-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-style-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-style-5.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-style-6.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-style-7.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-style-8.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-style-9.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-style-9.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-style-commands.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-verified-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-verified-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-verified-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-verified-2.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-verified-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-verified-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-verified-4.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-verified-5.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-verified-6.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-verified-6.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-verified-7.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-verified-7.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-verified-8.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-verified-8.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-verified-commands.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-ui-verified-identity.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-verified-source-identity.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-write-retry-final.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-write-retry-green-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-write-retry-green-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task4-write-retry-green-1.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-board-L_DebriefSlow-outline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-board-L_DebriefSlow-outline.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-board-L_DebriefSlow-timeline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-board-QV_All-outline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-board-QV_All-outline.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-board-QV_All-timeline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-board-QV_EndFree-outline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-board-QV_EndFree-outline.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-board-QV_EndFree-timeline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-board-QV_EndLastToday-outline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-board-QV_EndLastToday-outline.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-board-QV_EndLastToday-timeline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-board-QV_EndLowB-outline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-board-QV_EndLowB-outline.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-board-QV_EndLowB-timeline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-board-QV_EndPerfectB-outline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-board-QV_EndPerfectB-outline.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-board-QV_EndPerfectB-timeline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-board-QV_EndPro-outline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-board-QV_EndPro-outline.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-board-QV_EndPro-timeline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-board-QV_Sources-outline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-board-QV_Sources-outline.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-board-QV_Sources-timeline.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-checkpoint-callback-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-checkpoint-callback-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-checkpoint-callback-1.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-checkpoint-callback-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-checkpoint-callback-2.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-checkpoint-final-0-live.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-checkpoint-final-0-live.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-checkpoint-final-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-checkpoint-final-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-checkpoint-final-1.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-checkpoint-final-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-checkpoint-final-2.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-checkpoint-gates-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-checkpoint-gates-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-checkpoint-gates-1.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-checkpoint-gates-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-checkpoint-gates-2.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-cold-practice-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-cold-practice-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-combined-checkpoint-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-combined-checkpoint-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-combined-checkpoint-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-completion-cold-green.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-completion-cold-green.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-completion-cold-recheck.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-completion-consumer-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-completion-consumer-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-done-provenance-green.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-done-provenance-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-done-provenance-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-end-draft-manifest.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-end-draft-source.patch.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-explicit-next-green.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-final-focused.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-final-owned-analysis.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-final-owned-analysis.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-final-regression-renewed.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-affected.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-affected.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-analysis-draft.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-analysis-draft.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-analysis.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-analysis.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-bounded-analysis.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-bounded-analysis.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-bounded-green.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-bounded-manifest.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-bounded-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-bounded-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-commands.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-final.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-green-draft.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-green-draft.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-green-draft2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-green-draft2.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-green.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-manifest.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-motion-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-motion-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-verified-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-verified-0.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-verified-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-verified-1.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-verified-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-verified-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-verified-3.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-verified-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-verified-4.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-verified-5.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-gauge-verified-5.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-hydration-green-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-hydration-green-0.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-hydration-green-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-hydration-recheck-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-hydration-recheck-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-hydration-recheck-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-hydration-recheck-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-hydration-recheck-3.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-hydration-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-hydration-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-hydration-red2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-live-end-api-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-live-end-diagnostic.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-live-end-diagnostic.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-live-end-first-green.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-live-end-isolated-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-live-end-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-live-final-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-live-final-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-live-final-1.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-math-fallback-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-math-fallback-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-next-controller-api-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-next-controller-green.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-next-controller-green.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-next-controller-ready.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-next-controller-ready.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-next-controller-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-next-real-boundary.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-next-wipe-green.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-next-wipe-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-next-wipe-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-origin-affected.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-origin-analysis.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-origin-analysis.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-origin-commands.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-origin-green.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-origin-manifest.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-origin-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-origin-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-origin-verified-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-origin-verified-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-origin-verified-1.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-origin-verified-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-origin-verified-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-origin-verified-3.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-origin-verified-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-origin-verified-4.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-origin-verified-5.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-origin-verified-5.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-owned-analysis.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-owned-analysis.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-owned-style.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-owned-style.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-pending-pro-frame-green.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-pending-pro-frame-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-pending-pro-frame-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-pending-pro-green.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-pending-pro-green.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-pending-pro-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-pending-pro-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-ready-refresh-green.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-ready-refresh-green.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-ready-wipe-renewed.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-ready-wipe-renewed.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-resume-baseline-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-resume-baseline-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-resume-baseline-1.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-resume-checkpoint-manifest.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-resume-verified-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-resume-verified-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-resume-verified-1.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-resume-verified-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-resume-verified-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-resume-verified-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-route-identity-green.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-route-identity-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-route-identity-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-saved-static-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-saved-static-0.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-saved-static-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-saved-static-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-screen-analysis-diagnostic.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-screen-analysis-diagnostic.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-screen-behavior-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-screen-behavior-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-screen-green-draft.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-screen-green-draft.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-screen-green-draft2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-screen-green-draft3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-screen-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task5-stale-next-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-account-cache-green.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-account-cache-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-account-cache-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-all-boundaries.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-all-boundaries.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-boundary-data-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-boundary-data-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-compact-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-compact-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-consumer-boundaries-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-consumer-boundaries-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-consumer-boundaries-1.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-core-owner-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-core-owner-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-current-gates-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-current-gates-0.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-current-gates-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-current-gates-1.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-editor-first-green-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-editor-first-green-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-editor-first-green-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-editor-first-green-2.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-editor-motion-green.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-editor-motion-green.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-editor-motion-recheck.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-editor-motion-recheck.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-editor-motion-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-editor-motion-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-editor-recheck-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-editor-recheck-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-editor-recheck-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-editor-recheck-2.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-editor-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-editor-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-editor-unchanged-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-editor-unchanged-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-final-scoped-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-final-scoped-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-final-scoped-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-final-scoped-2.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-final-scoped-3.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-final-scoped-4.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-flag-unanswered-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-flag-unanswered-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-frame-consumer-green-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-frame-consumer-green-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-frame-consumer-green-1.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-frame-consumer-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-frame-consumer-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-frame-motion-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-frame-motion-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-motion-routes-green.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-motion-routes-green.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-notes-concurrent-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-notes-concurrent-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-notes-first-green-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-notes-first-green-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-notes-first-green-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-notes-tail-green.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-notes-tail-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-notes-tail-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-one-frame-motion-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-one-frame-motion-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-owned-style.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-owned-style.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-owner-guard-green-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-owner-guard-green-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-pro-drain-cleanup-timer.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-pro-post-write-coverage-check.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-pro-post-write-coverage-check.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-real-account-recheck.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-real-boundary-first.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-real-boundary-first.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-real-pro-diagnostic.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-real-pro-observed.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-real-pro-real-query.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-real-pro-teardown-diagnostic.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-saved-icon-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-saved-icon-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-shared-frame-manifest.json
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-shared-frame-verified-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-shared-frame-verified-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-shared-frame-verified-1.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-shared-frame-verified-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-stable-width-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-stable-width-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-stable-width-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-stable-width-2.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-standalone-checkpoint-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-standalone-checkpoint-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-standalone-checkpoint-1.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-standalone-checkpoint-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-viewer-first-green-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-viewer-first-green-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-viewer-first-green-1.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-viewer-first-green-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-viewer-first-green-2.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-viewer-metrics-green-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-viewer-metrics-green-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-viewer-metrics-green-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-viewer-metrics-green-2.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-viewer-note-focused-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-viewer-note-focused-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-viewer-note-focused-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-viewer-note-focused-2.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-viewer-note-recovery-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-viewer-note-recovery-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-viewer-note-recovery-1.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-viewer-note-recovery-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-viewer-note-recovery-2.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-viewer-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-viewer-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-viewer-routes-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task6-viewer-routes-red.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task9-owned-analysis.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task9-owned-analysis.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task9-retirement-analysis-renewed.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task9-retirement-analysis-renewed.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task9-retirement-focused-renewed.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task9-retirement-focused.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task9-retirement-focused.txt.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task9-scoped-final-0.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task9-scoped-final-1.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-task9-scoped-final-2.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-analysis-accepted.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-analysis-clean.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-analysis-ring.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-analysis-verified.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-analysis.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-analysis.txt.raw.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-attribution-verified.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-batch.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-boundaries-renewed.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-boundaries.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-complete.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-contract-api-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-contract-first.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-focused-accepted.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-focused-final.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-focused-renewed.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-focused-verified.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-format-accepted.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-format-clean.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-format-final.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-format-renewed.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-format-ring.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-format-verified.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-integration-analysis.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-integration-attribution.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-integration-diff.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-integration-fast-forward.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-integration-focused.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-integration-format.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-integration-generation.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-integration-layering.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-integration-status.json.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-interrupted-final-diff.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-interrupted-final-dirty.patch.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-interrupted-final-format.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-interrupted-final-full.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-interrupted-final-source-manifest.json.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-interrupted-final-status.json.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-launch.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-layering-verified.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-missing-review-red.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-owned-analysis.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-owned-analysis.txt.raw.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-retry-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-review-green.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-review-red.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-ring-red.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-ring-ring.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-sheet-api-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-sheet-green.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-style-clean.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-style-ring.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-takeover-failure-green.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-takeover-tests.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-ui-first.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-ui-green.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-ui-isolated-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-ui-real-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-ui-red.txt
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-verified-final-analysis.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-verified-final-attribution.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-verified-final-diff.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-verified-final-dirty.patch.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-verified-final-format-prepare.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-verified-final-format.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-verified-final-full.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-verified-final-layering.log.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-verified-final-source-manifest.json.gz
A  docs/superpowers/plans/new-design/evidence/logs/W4d-today-verified-final-status.json.gz
A  docs/superpowers/plans/pwa-launch/B9-lesson-svg-plan.md
A  docs/superpowers/plans/pwa-launch/evidence/B9-lesson-svg.md
A  docs/superpowers/specs/2026-10-21-w4e-cse-finale.md
 M functions/src/generated/pantas_core.js
 M functions/test/content-upload.test.mjs
M  lib/app/app.dart
M  lib/app/routes/home_routes.dart
M  lib/app/routes/mock_routes.dart
M  lib/app/routes/onboarding_routes.dart
M  lib/app/routes/quiz_routes.dart
MM lib/app/routes/settings_routes.dart
M  lib/app/routes/study_routes.dart
UU lib/core/content/bundle/protected_content_installer.dart
 M lib/core/content/bundle/protected_content_installer_native.dart
M  lib/core/content/content_database.dart
M  lib/core/content/domain/mock_blueprint.dart
M  lib/core/content/repos/mock_blueprint_repo.dart
M  lib/core/content/sanity/parsers/mock_blueprint_parser.dart
M  lib/core/content/security/content_package_manifest.dart
M  lib/core/content/tables/content_mock_blueprints.dart
R  lib/features/quiz/data/report_queue.dart -> lib/core/storage/data/report_queue.dart
M  lib/core/storage/data/repos/attempts_repository.dart
M  lib/core/storage/data/repos/custom_track_repository.dart
M  lib/core/storage/domain/assessment_question_selector.dart
M  lib/core/storage/storage.dart
M  lib/core/storage/track_scope.dart
D  lib/core/ui/components/accessible_math.dart
D  lib/core/ui/components/answer_reveal.dart
D  lib/core/ui/components/answer_row.dart
D  lib/core/ui/components/back_chevron.dart
D  lib/core/ui/components/board_button.dart
D  lib/core/ui/components/bookmark_ribbon.dart
M  lib/core/ui/components/centered_dialog.dart
M  lib/core/ui/components/check_mark.dart
D  lib/core/ui/components/confirmation_dialog.dart
M  lib/core/ui/components/content_renderer.dart
M  lib/core/ui/components/contents_glyph.dart
D  lib/core/ui/components/data_row_tile.dart
D  lib/core/ui/components/empty_state.dart
D  lib/core/ui/components/error_banner.dart
D  lib/core/ui/components/exam_date_sheet.dart
M  lib/core/ui/components/exam_name_line.dart
D  lib/core/ui/components/exam_selection_row.dart
D  lib/core/ui/components/faint_bars.dart
M  lib/core/ui/components/floating_bar.dart
M  lib/core/ui/components/grouped_section.dart
M  lib/core/ui/components/half_ring_gauge.dart
D  lib/core/ui/components/ink_checkbox.dart
D  lib/core/ui/components/ink_chevron.dart
D  lib/core/ui/components/ink_magnifier.dart
D  lib/core/ui/components/ink_plate_rule.dart
D  lib/core/ui/components/ink_sheet.dart
D  lib/core/ui/components/ink_table_row.dart
D  lib/core/ui/components/ink_wheel.dart
D  lib/core/ui/components/inline_math_text.dart
D  lib/core/ui/components/inline_meter.dart
M  lib/core/ui/components/list_row.dart
M  lib/core/ui/components/month_first_date_picker.dart
D  lib/core/ui/components/nav_glyph.dart
M  lib/core/ui/components/new_design/question_grid_sheet.dart
M  lib/core/ui/components/notice_strip.dart
D  lib/core/ui/components/page_scaffold.dart
M  lib/core/ui/components/pantas_button.dart
A  lib/core/ui/components/pantas_logo.dart
M  lib/core/ui/components/pantas_page.dart
M  lib/core/ui/components/pantas_sheet.dart
D  lib/core/ui/components/passage_card.dart
D  lib/core/ui/components/pennant_mark.dart
UD lib/core/ui/components/portable_text_renderer.dart
M  lib/core/ui/components/progress_ring.dart
D  lib/core/ui/components/progress_rule.dart
D  lib/core/ui/components/question_card.dart
D  lib/core/ui/components/question_grid_sheet.dart
D  lib/core/ui/components/quiz_progress_bar.dart
R  lib/features/quiz/presentation/report_form.dart -> lib/core/ui/components/report_form.dart
M  lib/core/ui/components/review_list.dart
D  lib/core/ui/components/ruled_panel.dart
D  lib/core/ui/components/ruled_section.dart
M  lib/core/ui/components/scope_picker.dart
D  lib/core/ui/components/section_header.dart
M  lib/core/ui/components/segmented_switch.dart
D  lib/core/ui/components/settings_bar.dart
D  lib/core/ui/components/settings_group.dart
D  lib/core/ui/components/settings_switch.dart
D  lib/core/ui/components/settings_value_row.dart
D  lib/core/ui/components/spaced_repetition_note.dart
M  lib/core/ui/components/state_view.dart
D  lib/core/ui/components/stats_band.dart
D  lib/core/ui/components/tab_header.dart
D  lib/core/ui/components/theme_control.dart
A  lib/core/ui/components/today_questions.dart
D  lib/core/ui/components/topic_scope_index.dart
M  lib/core/ui/components/value_wheel.dart
M  lib/core/ui/figures/biology_diagram_figure.dart
M  lib/core/ui/figures/chart_figure.dart
M  lib/core/ui/figures/chemistry_diagram_figure.dart
M  lib/core/ui/figures/concept_diagram_figure.dart
M  lib/core/ui/figures/coordinate_graph_figure.dart
M  lib/core/ui/figures/cube_net_figure.dart
M  lib/core/ui/figures/earth_science_diagram_figure.dart
M  lib/core/ui/figures/figure_matrix_figure.dart
M  lib/core/ui/figures/figure_series_figure.dart
M  lib/core/ui/figures/fluid_vessel_figure.dart
M  lib/core/ui/figures/gear_train_figure.dart
M  lib/core/ui/figures/geometry_diagram_figure.dart
M  lib/core/ui/figures/lesson_figure_widget.dart
M  lib/core/ui/figures/lever_balance_figure.dart
M  lib/core/ui/figures/paper_fold_figure.dart
M  lib/core/ui/figures/physics_energy_diagram_figure.dart
M  lib/core/ui/figures/physics_mechanics_diagram_figure.dart
M  lib/core/ui/figures/pulley_system_figure.dart
M  lib/core/ui/figures/question_figure.dart
M  lib/core/ui/figures/reading_diagram_figure.dart
M  lib/core/ui/figures/shape_row_figure.dart
M  lib/core/ui/figures/spring_scale_figure.dart
M  lib/core/ui/figures/stability_shape_figure.dart
M  lib/core/ui/icons/pantas_icons.dart
M  lib/core/ui/severity.dart
D  lib/core/ui/theme/app_colors.dart
D  lib/core/ui/theme/app_dimensions.dart
D  lib/core/ui/theme/app_text_styles.dart
M  lib/core/ui/theme/app_theme.dart
M  lib/core/ui/theme/font_licenses.dart
M  lib/core/ui/theme/pantas_colors.dart
M  lib/core/ui/theme/pantas_type.dart
M  lib/features/assessment/domain/models/assessment_session.dart
M  lib/features/assessment/domain/use_cases/complete_assessment.dart
M  lib/features/assessment/domain/use_cases/start_assessment.dart
M  lib/features/assessment/presentation/assessment_page.dart
M  lib/features/assessment/presentation/assessment_results_page.dart
A  lib/features/home/application/home_day_extras.dart
A  lib/features/home/application/home_notices.dart
A  lib/features/home/application/home_today.dart
M  lib/features/home/application/how_you_work_provider.dart
A  lib/features/home/application/performance/performance_view.dart
A  lib/features/home/application/performance/topic_detail.dart
A  lib/features/home/application/plan_data.dart
A  lib/features/home/application/plan_provider.dart
M  lib/features/home/application/record_provider.dart
A  lib/features/home/application/server_tendencies.dart
A  lib/features/home/application/server_today.dart
A  lib/features/home/application/study_delivery.dart
A  lib/features/home/application/study_remote_providers.dart
D  lib/features/home/application/tendencies_provider.dart
A  lib/features/home/application/today_questions.dart
D  lib/features/home/application/up_next_provider.dart
A  lib/features/home/application/web_study_seam.dart
A  lib/features/home/data/plan_history_reader.dart
A  lib/features/home/data/study_api.dart
A  lib/features/home/data/study_observations.dart
A  lib/features/home/data/study_read_cache.dart
A  lib/features/home/data/study_snapshot_reader.dart
A  lib/features/home/data/study_writes.dart
A  lib/features/home/domain/home_day_note.dart
A  lib/features/home/domain/home_mock_row.dart
A  lib/features/home/domain/home_today_lesson.dart
A  lib/features/home/domain/home_today_view.dart
A  lib/features/home/domain/study_models.dart
M  lib/features/home/presentation/home_providers.dart
M  lib/features/home/presentation/home_tab.dart
A  lib/features/home/presentation/home_today_screen.dart
A  lib/features/home/presentation/performance_page.dart
A  lib/features/home/presentation/performance_screen.dart
A  lib/features/home/presentation/plan_day_page.dart
A  lib/features/home/presentation/plan_page.dart
A  lib/features/home/presentation/plan_screen.dart
A  lib/features/home/presentation/practice_launcher.dart
A  lib/features/home/presentation/record_page.dart
A  lib/features/home/presentation/record_screen.dart
A  lib/features/home/presentation/tendencies_page.dart
A  lib/features/home/presentation/tendencies_screen.dart
A  lib/features/home/presentation/topic_detail_page.dart
R  lib/features/progress/presentation/widgets/accuracy_line.dart -> lib/features/home/presentation/widgets/accuracy_line.dart
A  lib/features/home/presentation/widgets/home_exam_date_sheet.dart
A  lib/features/home/presentation/widgets/home_exam_day.dart
M  lib/features/home/presentation/widgets/home_masthead.dart
A  lib/features/home/presentation/widgets/home_notice_strip.dart
A  lib/features/home/presentation/widgets/home_performance_card.dart
A  lib/features/home/presentation/widgets/home_performance_section.dart
A  lib/features/home/presentation/widgets/home_state_card.dart
D  lib/features/home/presentation/widgets/home_stats_band.dart
A  lib/features/home/presentation/widgets/home_today_checklist.dart
D  lib/features/home/presentation/widgets/practice_panel.dart
D  lib/features/home/presentation/widgets/tendencies_panel.dart
D  lib/features/home/presentation/widgets/tendency_card.dart
D  lib/features/home/presentation/widgets/up_next_panel.dart
M  lib/features/legal/domain/legal_document.dart
M  lib/features/legal/presentation/legal_document_page.dart
M  lib/features/lesson/application/bookmark_providers.dart
M  lib/features/lesson/application/reader_providers.dart
M  lib/features/lesson/data/repos/bookmark_prefs_repository.dart
M  lib/features/lesson/data/repos/reader_position_repository.dart
M  lib/features/lesson/domain/models/bookmark_order.dart
M  lib/features/lesson/domain/use_cases/decide_ending.dart
D  lib/features/lesson/domain/use_cases/dismiss_quiz_nudge.dart
M  lib/features/lesson/lesson.dart
M  lib/features/lesson/presentation/learn_tab_home.dart
M  lib/features/lesson/presentation/lesson_page.dart
M  lib/features/lesson/presentation/pages/topic_ending_page.dart
M  lib/features/lesson/presentation/widgets/bookmarks_section.dart
M  lib/features/lesson/presentation/widgets/bookmarks_sheet.dart
D  lib/features/lesson/presentation/widgets/bookplate.dart
A  lib/features/lesson/presentation/widgets/ending_content.dart
M  lib/features/lesson/presentation/widgets/lesson_contents_sheet.dart
D  lib/features/lesson/presentation/widgets/next_topic_block.dart
M  lib/features/lesson/presentation/widgets/pull_to_advance.dart
M  lib/features/lesson/presentation/widgets/reader_bar.dart
M  lib/features/lesson/presentation/widgets/reader_gap.dart
M  lib/features/lesson/presentation/widgets/reader_rail.dart
M  lib/features/lesson/presentation/widgets/study_topic_section.dart
M  lib/features/metrics/data/user_metrics_archetype_repository.dart
M  lib/features/metrics/providers/current_archetype_provider.dart
M  lib/features/mock_exam/application/mock_availability_provider.dart
M  lib/features/mock_exam/application/mock_exam_preferences.dart
M  lib/features/mock_exam/application/mock_panel_providers.dart
M  lib/features/mock_exam/application/mock_persistence_scheduler.dart
M  lib/features/mock_exam/application/mock_results_providers.dart
M  lib/features/mock_exam/application/mock_review_providers.dart
M  lib/features/mock_exam/application/mock_session_controller.dart
A  lib/features/mock_exam/application/server_mock_providers.dart
A  lib/features/mock_exam/application/server_mock_results_providers.dart
A  lib/features/mock_exam/application/server_mock_session.dart
M  lib/features/mock_exam/application/strict_mode_lifecycle.dart
M  lib/features/mock_exam/data/blueprint_section.dart
A  lib/features/mock_exam/data/server_mock_api.dart
A  lib/features/mock_exam/data/server_mock_view_cache.dart
M  lib/features/mock_exam/domain/custom_blueprint.dart
M  lib/features/mock_exam/domain/mock_availability.dart
M  lib/features/mock_exam/domain/mock_session_snapshot.dart
M  lib/features/mock_exam/domain/mock_session_state.dart
M  lib/features/mock_exam/domain/part_clock.dart
A  lib/features/mock_exam/domain/server_mock_paper.dart
A  lib/features/mock_exam/domain/server_mock_results.dart
M  lib/features/mock_exam/domain/use_cases/resume_mock.dart
M  lib/features/mock_exam/mock_exam.dart
M  lib/features/mock_exam/presentation/clock_rule.dart
A  lib/features/mock_exam/presentation/mock_hourglass.dart
M  lib/features/mock_exam/presentation/pages/custom_mock_setup_page.dart
M  lib/features/mock_exam/presentation/pages/custom_mock_setup_route.dart
D  lib/features/mock_exam/presentation/pages/mock_history_page.dart
M  lib/features/mock_exam/presentation/pages/mock_results_page.dart
M  lib/features/mock_exam/presentation/pages/mock_results_route.dart
M  lib/features/mock_exam/presentation/pages/mock_review_page.dart
M  lib/features/mock_exam/presentation/pages/mock_session_page.dart
M  lib/features/mock_exam/presentation/pages/mock_setup_page.dart
M  lib/features/mock_exam/presentation/pages/mock_setup_route.dart
A  lib/features/mock_exam/presentation/pages/mock_start_preparation_page.dart
M  lib/features/mock_exam/presentation/pages/mock_start_route.dart
A  lib/features/mock_exam/presentation/pages/server_mock_route.dart
M  lib/features/mock_exam/presentation/part_transition_page.dart
M  lib/features/mock_exam/presentation/pause_page.dart
M  lib/features/mock_exam/presentation/proctor_toast.dart
A  lib/features/mock_exam/presentation/widgets/cse_finale_motion.dart
A  lib/features/mock_exam/presentation/widgets/cse_finale_tracks.dart
A  lib/features/mock_exam/presentation/widgets/cse_mock_finale.dart
M  lib/features/mock_exam/presentation/widgets/exam_marks_offer.dart
M  lib/features/mock_exam/presentation/widgets/mock_card.dart
A  lib/features/mock_exam/presentation/widgets/mock_finale.dart
D  lib/features/mock_exam/presentation/widgets/mock_floating_bar.dart
D  lib/features/mock_exam/presentation/widgets/mock_panel.dart
D  lib/features/mock_exam/presentation/widgets/mock_question_grid.dart
M  lib/features/mock_exam/presentation/widgets/mock_resume_sheet.dart
M  lib/features/mock_exam/presentation/widgets/mock_status_card.dart
D  lib/features/mock_exam/presentation/widgets/question_navigator_sheet.dart
M  lib/features/mock_exam/presentation/widgets/score_headline.dart
D  lib/features/mock_exam/presentation/widgets/value_wheel_sheet.dart
M  lib/features/notifications/presentation/permission_rationale_page.dart
A  lib/features/onboarding/application/onboarding_flow.dart
A  lib/features/onboarding/presentation/exam_picker_screen.dart
M  lib/features/onboarding/presentation/onboarding_age_gate_step.dart
M  lib/features/onboarding/presentation/onboarding_consent_step.dart
M  lib/features/onboarding/presentation/onboarding_exam_date_step.dart
A  lib/features/onboarding/presentation/onboarding_name_field.dart
M  lib/features/onboarding/presentation/onboarding_name_step.dart
M  lib/features/onboarding/presentation/onboarding_page.dart
D  lib/features/onboarding/presentation/onboarding_picker_step.dart
A  lib/features/onboarding/presentation/onboarding_study_days_step.dart
M  lib/features/onboarding/presentation/onboarding_welcome_step.dart
M  lib/features/onboarding/presentation/steps/custom_track_name_step.dart
M  lib/features/onboarding/presentation/steps/custom_track_subjects_step.dart
M  lib/features/paywall/application/paywall_providers.dart
D  lib/features/paywall/domain/paywall_recommendation.dart
M  lib/features/paywall/paywall.dart
D  lib/features/paywall/presentation/paywall_package_card.dart
D  lib/features/paywall/presentation/paywall_page.dart
D  lib/features/paywall/presentation/plan_row.dart
D  lib/features/paywall/presentation/plans_page.dart
D  lib/features/paywall/presentation/pro_specimen_panel.dart
D  lib/features/paywall/presentation/pro_welcome_banner.dart
D  lib/features/paywall/presentation/subscription_panel.dart
D  lib/features/paywall/presentation/trial_notice_banner.dart
D  lib/features/paywall/presentation/trial_timeline_page.dart
D  lib/features/paywall/presentation/what_pro_adds_page.dart
D  lib/features/progress/application/pace_provider.dart
D  lib/features/progress/presentation/pages/how_you_work_page.dart
D  lib/features/progress/presentation/pages/your_record_page.dart
D  lib/features/progress/presentation/progress_page.dart
D  lib/features/progress/presentation/widgets/gap_comparison.dart
D  lib/features/progress/presentation/widgets/level_control.dart
D  lib/features/progress/presentation/widgets/performance_section.dart
D  lib/features/progress/presentation/widgets/subject_scope_sheet.dart
D  lib/features/progress/presentation/widgets/table_head.dart
D  lib/features/progress/presentation/widgets/why_you_miss_section.dart
D  lib/features/progress/presentation/widgets/your_pace_panel.dart
A  lib/features/quiz/application/completed_quiz.dart
M  lib/features/quiz/application/quiz_completion_coordinator.dart
A  lib/features/quiz/application/quiz_launch_guard.dart
M  lib/features/quiz/application/quiz_providers.dart
M  lib/features/quiz/application/today_quiz_preparer.dart
A  lib/features/quiz/data/repos/practice_preferences_repository.dart
M  lib/features/quiz/data/repos/quiz_session_repository.dart
A  lib/features/quiz/data/repos/review_batch_repository.dart
M  lib/features/quiz/domain/debrief/session_debrief.dart
A  lib/features/quiz/domain/models/review_batch.dart
A  lib/features/quiz/domain/models/review_batch_position.dart
M  lib/features/quiz/domain/models/session_origin.dart
M  lib/features/quiz/domain/picker/practice_selection.dart
M  lib/features/quiz/domain/picker/practice_summary.dart
M  lib/features/quiz/domain/quiz_session.dart
M  lib/features/quiz/domain/use_cases/resume_session.dart
M  lib/features/quiz/domain/use_cases/start_practice.dart
A  lib/features/quiz/presentation/completed_quiz_provider.dart
M  lib/features/quiz/presentation/debrief_providers.dart
D  lib/features/quiz/presentation/pages/debrief_page.dart
M  lib/features/quiz/presentation/pages/flagged_list_page.dart
D  lib/features/quiz/presentation/pages/practice_picker_page.dart
M  lib/features/quiz/presentation/practice_picker_providers.dart
A  lib/features/quiz/presentation/practice_picker_screen.dart
M  lib/features/quiz/presentation/question_flag_providers.dart
M  lib/features/quiz/presentation/quiz_controller.dart
A  lib/features/quiz/presentation/quiz_note_boundary.dart
A  lib/features/quiz/presentation/quiz_note_editor.dart
M  lib/features/quiz/presentation/quiz_page.dart
A  lib/features/quiz/presentation/quiz_question_viewer.dart
D  lib/features/quiz/presentation/quiz_results_page.dart
A  lib/features/quiz/presentation/quiz_review_page.dart
A  lib/features/quiz/presentation/quiz_session_end_page.dart
D  lib/features/quiz/presentation/quiz_tab_home.dart
A  lib/features/quiz/presentation/quiz_tab_screen.dart
M  lib/features/quiz/presentation/review_providers.dart
A  lib/features/quiz/presentation/session_end_screen.dart
M  lib/features/quiz/presentation/today_providers.dart
D  lib/features/quiz/presentation/widgets/length_wheel.dart
D  lib/features/quiz/presentation/widgets/session_panel.dart
M  lib/features/quiz/quiz.dart
M  lib/features/roadmap/application/roadmap_inputs_reader.dart
M  lib/features/roadmap/application/roadmap_providers.dart
M  lib/features/settings/application/settings_providers.dart
M  lib/features/settings/data/settings_repository.dart
M  lib/features/settings/domain/backup_status.dart
M  lib/features/settings/domain/delete_account_copy.dart
A  lib/features/settings/domain/exam_change_result.dart
M  lib/features/settings/presentation/carry_over_prompt.dart
M  lib/features/settings/presentation/pages/about_page.dart
M  lib/features/settings/presentation/pages/account_page.dart
A  lib/features/settings/presentation/pages/appearance_page.dart
M  lib/features/settings/presentation/pages/backup_page.dart
D  lib/features/settings/presentation/pages/change_exam_page.dart
M  lib/features/settings/presentation/pages/delete_account_page.dart
M  lib/features/settings/presentation/pages/exam_page.dart
A  lib/features/settings/presentation/pages/name_page.dart
D  lib/features/settings/presentation/pages/not_built_yet_page.dart
M  lib/features/settings/presentation/pages/pro_page.dart
M  lib/features/settings/presentation/pages/session_building_page.dart
M  lib/features/settings/presentation/pages/whats_included_page.dart
M  lib/features/settings/presentation/settings_home_page.dart
M  lib/features/settings/presentation/settings_value_formats.dart
D  lib/features/settings/presentation/sheets/name_sheet.dart
D  lib/features/settings/presentation/sheets/ordering_sheet.dart
D  lib/features/settings/presentation/sheets/reminder_sheet.dart
M  lib/features/settings/presentation/widgets/sync_reconciliation_gate.dart
M  lib/features/shell/presentation/app_shell.dart
M  lib/features/wrapped/presentation/my_shared_cards_page.dart
M  lib/features/wrapped/presentation/share_privacy_sheet.dart
M  lib/features/wrapped/presentation/wrapped_reveal_page.dart
M  pubspec.yaml
M  test/app/router_mock_panel_test.dart
M  test/app/router_onboarding_completion_test.dart
UU test/app/router_paths_preserved_test.dart
UU test/app/router_redirect_test.dart
M  test/app/router_settings_test.dart
M  test/app/study_route_test.dart
M  test/core/content/bundle/protected_content_installer_test.dart
A  test/core/content/content_database_migration_test.dart
M  test/core/content/content_database_query_plan_test.dart
M  test/core/content/content_database_test.dart
M  test/core/content/sanity/parsers/mock_blueprint_parser_test.dart
M  test/core/content/security/content_package_manifest_test.dart
R  test/features/quiz/data/report_queue_test.dart -> test/core/storage/data/report_queue_test.dart
A  test/core/storage/data/repos/attempts_repository_notes_test.dart
MM test/core/storage/data/repos/custom_track_repository_test.dart
M  test/core/sync/silent_sync_test.dart
M  test/core/ui/components/accessibility_test.dart
D  test/core/ui/components/answer_reveal_test.dart
D  test/core/ui/components/answer_row_test.dart
D  test/core/ui/components/board_button_test.dart
D  test/core/ui/components/confirmation_dialog_test.dart
A  test/core/ui/components/contents_glyph_reader_test.dart
D  test/core/ui/components/data_row_tile_test.dart
M  test/core/ui/components/destructive_contrast_test.dart
A  test/core/ui/components/disabled_action_label_test.dart
D  test/core/ui/components/empty_state_test.dart
D  test/core/ui/components/error_banner_test.dart
D  test/core/ui/components/exam_date_sheet_test.dart
M  test/core/ui/components/exam_name_line_test.dart
A  test/core/ui/components/exam_picker_extensions_test.dart
D  test/core/ui/components/exam_selection_row_test.dart
D  test/core/ui/components/faint_bars_test.dart
A  test/core/ui/components/floating_bar_motion_override_test.dart
A  test/core/ui/components/half_ring_gauge_quiz_count_test.dart
M  test/core/ui/components/half_ring_gauge_test.dart
D  test/core/ui/components/ink_checkbox_test.dart
D  test/core/ui/components/ink_chevron_test.dart
D  test/core/ui/components/ink_plate_rule_test.dart
D  test/core/ui/components/ink_sheet_test.dart
D  test/core/ui/components/ink_table_row_test.dart
D  test/core/ui/components/ink_wheel_test.dart
D  test/core/ui/components/inline_math_text_test.dart
AA test/core/ui/components/lesson_svg_test.dart
A  test/core/ui/components/list_row_title_widget_test.dart
M  test/core/ui/components/math_accessibility_test.dart
A  test/core/ui/components/mock_gauge_reveal_test.dart
A  test/core/ui/components/mock_shared_contract_test.dart
D  test/core/ui/components/nav_glyph_test.dart
A  test/core/ui/components/neutral_button_test.dart
A  test/core/ui/components/onboarding_date_extensions_test.dart
A  test/core/ui/components/onboarding_extensions_test.dart
D  test/core/ui/components/pennant_mark_test.dart
D  test/core/ui/components/portable_text_renderer_test.dart
A  test/core/ui/components/practice_page_extensions_test.dart
A  test/core/ui/components/practice_scope_extensions_test.dart
D  test/core/ui/components/progress_rule_test.dart
A  test/core/ui/components/pull_ring_test.dart
D  test/core/ui/components/question_card_test.dart
D  test/core/ui/components/question_grid_sheet_test.dart
A  test/core/ui/components/quiz_row_extensions_test.dart
A  test/core/ui/components/reader_contents_sheet_variant_test.dart
R  test/features/quiz/presentation/report_form_test.dart -> test/core/ui/components/report_form_test.dart
M  test/core/ui/components/review_list_test.dart
D  test/core/ui/components/ruled_panel_test.dart
D  test/core/ui/components/ruled_section_test.dart
D  test/core/ui/components/section_header_test.dart
D  test/core/ui/components/settings_group_test.dart
D  test/core/ui/components/settings_switch_test.dart
D  test/core/ui/components/settings_value_row_test.dart
D  test/core/ui/components/spaced_repetition_note_test.dart
A  test/core/ui/components/state_view_bookmark_layout_test.dart
D  test/core/ui/components/stats_band_test.dart
M  test/core/ui/components/study_map_extensions_test.dart
D  test/core/ui/components/tab_header_test.dart
D  test/core/ui/components/theme_control_test.dart
A  test/core/ui/components/today_questions_test.dart
D  test/core/ui/components/topic_scope_index_test.dart
M  test/core/ui/figures/lesson_original_code_a_test.dart
M  test/core/ui/figures/lesson_original_code_b_test.dart
M  test/core/ui/icons/pantas_icons_test.dart
D  test/core/ui/theme/app_colors_test.dart
D  test/core/ui/theme/app_dimensions_test.dart
D  test/core/ui/theme/app_text_styles_test.dart
M  test/core/ui/theme/app_theme_test.dart
M  test/core/ui/theme/font_licenses_test.dart
M  test/core/ui/theme/fonts_declared_test.dart
M  test/core/ui/theme/pantas_theme_test.dart
M  test/core/ui/theme/pantas_type_test.dart
M  test/features/assessment/domain/services/assessment_question_selector_test.dart
M  test/features/assessment/domain/use_cases/complete_assessment_test.dart
M  test/features/assessment/presentation/assessment_page_test.dart
M  test/features/assessment/presentation/assessment_results_page_test.dart
A  test/features/home/application/home_day_extras_test.dart
A  test/features/home/application/home_notices_test.dart
A  test/features/home/application/home_today_launch_test.dart
M  test/features/home/application/how_you_work_provider_test.dart
A  test/features/home/application/performance/performance_view_provider_test.dart
A  test/features/home/application/performance/topic_detail_test.dart
A  test/features/home/application/plan_data_test.dart
M  test/features/home/application/record_provider_test.dart
A  test/features/home/application/record_server_history_test.dart
A  test/features/home/application/record_sunday_test.dart
A  test/features/home/application/server_tendencies_test.dart
A  test/features/home/application/server_today_test.dart
A  test/features/home/application/study_coverage_test.dart
A  test/features/home/application/study_remote_providers_test.dart
D  test/features/home/application/tendencies_provider_test.dart
D  test/features/home/application/up_next_provider_test.dart
A  test/features/home/application/web_study_seam_test.dart
A  test/features/home/data/plan_history_reader_test.dart
A  test/features/home/data/study_api_test.dart
A  test/features/home/data/study_observations_test.dart
A  test/features/home/data/study_read_cache_test.dart
A  test/features/home/data/study_snapshot_reader_test.dart
A  test/features/home/data/study_writes_test.dart
A  test/features/home/domain/home_day_note_test.dart
A  test/features/home/domain/home_mock_row_test.dart
A  test/features/home/domain/home_today_view_test.dart
A  test/features/home/domain/study_models_test.dart
M  test/features/home/presentation/home_tab_test.dart
A  test/features/home/presentation/home_today_screen_test.dart
A  test/features/home/presentation/home_week_strip_provider_test.dart
A  test/features/home/presentation/performance_page_test.dart
A  test/features/home/presentation/performance_screen_test.dart
A  test/features/home/presentation/plan_day_page_test.dart
A  test/features/home/presentation/plan_page_test.dart
A  test/features/home/presentation/plan_screen_test.dart
A  test/features/home/presentation/practice_launcher_test.dart
A  test/features/home/presentation/record_page_test.dart
A  test/features/home/presentation/record_screen_test.dart
A  test/features/home/presentation/tendencies_page_test.dart
A  test/features/home/presentation/topic_detail_page_test.dart
R  test/features/progress/presentation/widgets/accuracy_line_test.dart -> test/features/home/presentation/widgets/accuracy_line_test.dart
A  test/features/home/presentation/widgets/home_exam_date_sheet_test.dart
A  test/features/home/presentation/widgets/home_exam_day_test.dart
M  test/features/home/presentation/widgets/home_masthead_test.dart
A  test/features/home/presentation/widgets/home_notice_strip_test.dart
A  test/features/home/presentation/widgets/home_performance_card_test.dart
A  test/features/home/presentation/widgets/home_performance_section_test.dart
A  test/features/home/presentation/widgets/home_state_card_test.dart
D  test/features/home/presentation/widgets/home_stats_band_test.dart
A  test/features/home/presentation/widgets/home_today_checklist_test.dart
D  test/features/home/presentation/widgets/practice_panel_test.dart
D  test/features/home/presentation/widgets/tendencies_panel_test.dart
D  test/features/home/presentation/widgets/tendency_card_test.dart
D  test/features/home/presentation/widgets/up_next_panel_test.dart
M  test/features/legal/domain/legal_document_test.dart
M  test/features/legal/presentation/legal_document_page_test.dart
M  test/features/lesson/application/bookmark_providers_test.dart
M  test/features/lesson/application/read_marking_test.dart
M  test/features/lesson/application/reader_providers_test.dart
M  test/features/lesson/application/study_map_providers_test.dart
M  test/features/lesson/data/bookmark_prefs_repository_test.dart
M  test/features/lesson/data/reader_position_repository_test.dart
M  test/features/lesson/domain/decide_ending_test.dart
D  test/features/lesson/domain/use_cases/dismiss_quiz_nudge_test.dart
M  test/features/lesson/presentation/bookmarks_section_test.dart
M  test/features/lesson/presentation/bookmarks_sheet_test.dart
D  test/features/lesson/presentation/bookplate_test.dart
A  test/features/lesson/presentation/contents_board_test.dart
A  test/features/lesson/presentation/ending_board_test.dart
M  test/features/lesson/presentation/learn_tab_home_test.dart
D  test/features/lesson/presentation/lesson_contents_sheet_test.dart
M  test/features/lesson/presentation/lesson_page_progress_test.dart
M  test/features/lesson/presentation/lesson_page_test.dart
M  test/features/lesson/presentation/pull_to_advance_test.dart
A  test/features/lesson/presentation/quiz_entry_test.dart
M  test/features/lesson/presentation/reader_bar_test.dart
M  test/features/lesson/presentation/reader_body_board_test.dart
A  test/features/lesson/presentation/reader_boundary_test.dart
M  test/features/lesson/presentation/reader_gap_test.dart
M  test/features/lesson/presentation/reader_rail_test.dart
M  test/features/lesson/presentation/reader_states_test.dart
M  test/features/lesson/presentation/study_map_page_test.dart
M  test/features/lesson/presentation/study_states_board_test.dart
M  test/features/lesson/presentation/study_topic_section_test.dart
M  test/features/lesson/presentation/topic_ending_page_test.dart
AA test/features/metrics/archetypes/archetype_identity_test.dart
UU test/features/metrics/archetypes/archetype_templates_test.dart
UU test/features/metrics/providers/current_archetype_provider_test.dart
M  test/features/mock_exam/application/mock_exam_preferences_test.dart
A  test/features/mock_exam/application/mock_result_access_test.dart
M  test/features/mock_exam/application/mock_session_controller_test.dart
M  test/features/mock_exam/application/mock_session_parts_test.dart
A  test/features/mock_exam/application/server_mock_results_providers_test.dart
A  test/features/mock_exam/application/server_mock_session_test.dart
M  test/features/mock_exam/application/strict_mode_lifecycle_test.dart
M  test/features/mock_exam/data/blueprint_section_test.dart
M  test/features/mock_exam/data/custom_blueprint_repository_test.dart
A  test/features/mock_exam/data/server_mock_api_test.dart
A  test/features/mock_exam/data/server_mock_results_test.dart
A  test/features/mock_exam/data/server_mock_view_cache_test.dart
AM test/features/mock_exam/data/task3_mock_blueprints_test.dart
A  test/features/mock_exam/domain/between_parts_recovery_test.dart
M  test/features/mock_exam/domain/part_clock_test.dart
A  test/features/mock_exam/domain/server_mock_paper_test.dart
M  test/features/mock_exam/mock_panel_states_test.dart
A  test/features/mock_exam/presentation/approved_details_accessibility_test.dart
A  test/features/mock_exam/presentation/between_parts_route_test.dart
M  test/features/mock_exam/presentation/clock_rule_test.dart
A  test/features/mock_exam/presentation/cse_finale_chart_motion_test.dart
A  test/features/mock_exam/presentation/cse_finale_motion_test.dart
A  test/features/mock_exam/presentation/cse_finale_route_test.dart
A  test/features/mock_exam/presentation/cse_mock_finale_test.dart
M  test/features/mock_exam/presentation/custom_mock_setup_page_test.dart
M  test/features/mock_exam/presentation/end_part_early_test.dart
M  test/features/mock_exam/presentation/mock_card_test.dart
A  test/features/mock_exam/presentation/mock_finale_test.dart
D  test/features/mock_exam/presentation/mock_history_page_test.dart
D  test/features/mock_exam/presentation/mock_panel_custom_test.dart
D  test/features/mock_exam/presentation/mock_panel_test.dart
A  test/features/mock_exam/presentation/mock_result_destination_test.dart
M  test/features/mock_exam/presentation/mock_results_page_test.dart
M  test/features/mock_exam/presentation/mock_review_page_test.dart
M  test/features/mock_exam/presentation/mock_session_page_test.dart
M  test/features/mock_exam/presentation/mock_setup_page_test.dart
M  test/features/mock_exam/presentation/mock_start_route_persistence_test.dart
M  test/features/mock_exam/presentation/pages/mock_session_page_test.dart
M  test/features/mock_exam/presentation/pages/mock_setup_page_test.dart
A  test/features/mock_exam/presentation/pages/mock_start_preparation_page_test.dart
A  test/features/mock_exam/presentation/paper_phone_accessibility_test.dart
M  test/features/mock_exam/presentation/part_transition_page_test.dart
M  test/features/mock_exam/presentation/pause_page_test.dart
M  test/features/mock_exam/presentation/proctor_toast_test.dart
D  test/features/mock_exam/presentation/question_navigator_sheet_test.dart
A  test/features/mock_exam/presentation/server_mock_retry_test.dart
A  test/features/mock_exam/presentation/server_mock_route_test.dart
A  test/features/mock_exam/presentation/task4_grid_submit_test.dart
A  test/features/mock_exam/presentation/task4_paper_contract_test.dart
A  test/features/mock_exam/presentation/task4_paper_motion_test.dart
A  test/features/mock_exam/presentation/task4_route_test.dart
A  test/features/mock_exam/presentation/task5_recovery_test.dart
D  test/features/mock_exam/presentation/value_wheel_sheet_test.dart
D  test/features/mock_exam/presentation/widgets/mock_floating_bar_test.dart
D  test/features/mock_exam/presentation/widgets/mock_question_grid_test.dart
M  test/features/mock_exam/upcat_end_to_end_test.dart
A  test/features/onboarding/application/onboarding_flow_test.dart
A  test/features/onboarding/application/onboarding_resume_storage_test.dart
M  test/features/onboarding/onboarding_telemetry_test.dart
M  test/features/onboarding/presentation/custom_track_steps_test.dart
A  test/features/onboarding/presentation/exam_picker_screen_test.dart
M  test/features/onboarding/presentation/onboarding_age_gate_step_test.dart
M  test/features/onboarding/presentation/onboarding_consent_step_test.dart
A  test/features/onboarding/presentation/onboarding_custom_back_test.dart
A  test/features/onboarding/presentation/onboarding_error_reporting_test.dart
M  test/features/onboarding/presentation/onboarding_exam_date_step_test.dart
A  test/features/onboarding/presentation/onboarding_launch_step_test.dart
A  test/features/onboarding/presentation/onboarding_load_failure_test.dart
M  test/features/onboarding/presentation/onboarding_name_step_test.dart
M  test/features/onboarding/presentation/onboarding_page_test.dart
D  test/features/onboarding/presentation/onboarding_picker_step_test.dart
A  test/features/onboarding/presentation/onboarding_study_days_step_test.dart
A  test/features/onboarding/presentation/onboarding_web_completion_test.dart
M  test/features/onboarding/presentation/onboarding_welcome_step_test.dart
M  test/features/paywall/application/paywall_providers_test.dart
M  test/features/paywall/data/trial_eligibility_test.dart
D  test/features/paywall/domain/paywall_recommendation_test.dart
M  test/features/paywall/presentation/payment_presentation_source_guard_test.dart
D  test/features/paywall/presentation/paywall_offline_copy_test.dart
D  test/features/paywall/presentation/paywall_page_test.dart
D  test/features/paywall/presentation/plans_page_test.dart
D  test/features/paywall/presentation/pro_specimen_panel_test.dart
D  test/features/paywall/presentation/pro_welcome_banner_test.dart
D  test/features/paywall/presentation/subscription_panel_test.dart
D  test/features/paywall/presentation/trial_notice_banner_test.dart
D  test/features/paywall/presentation/trial_timeline_page_test.dart
D  test/features/paywall/presentation/what_pro_adds_page_test.dart
D  test/features/progress/application/pace_provider_test.dart
D  test/features/progress/mock_feeds_progress_test.dart
D  test/features/progress/presentation/pages/how_you_work_page_test.dart
D  test/features/progress/presentation/pages/your_record_page_test.dart
D  test/features/progress/presentation/progress_page_test.dart
D  test/features/progress/presentation/widgets/gap_comparison_test.dart
D  test/features/progress/presentation/widgets/level_control_test.dart
D  test/features/progress/presentation/widgets/performance_section_test.dart
D  test/features/progress/presentation/widgets/subject_scope_test.dart
D  test/features/progress/presentation/widgets/table_head_test.dart
D  test/features/progress/presentation/widgets/why_you_miss_section_test.dart
D  test/features/progress/presentation/widgets/your_pace_panel_test.dart
A  test/features/quiz/application/review_batch_scope_test.dart
A  test/features/quiz/application/today_question_launch_test.dart
A  test/features/quiz/application/today_question_ui_test.dart
A  test/features/quiz/data/repos/practice_preferences_repository_test.dart
A  test/features/quiz/data/review_batch_repository_test.dart
A  test/features/quiz/domain/picker/practice_adjustment_test.dart
A  test/features/quiz/domain/picker/practice_design_rules_test.dart
A  test/features/quiz/domain/picker/practice_mode_match_test.dart
M  test/features/quiz/domain/picker/practice_selection_test.dart
M  test/features/quiz/domain/picker/practice_summary_test.dart
A  test/features/quiz/domain/use_cases/flagged_origin_test.dart
A  test/features/quiz/domain/use_cases/flagged_start_missing_test.dart
A  test/features/quiz/domain/use_cases/practice_recency_test.dart
M  test/features/quiz/domain/use_cases/start_practice_test.dart
M  test/features/quiz/integration_test.dart
M  test/features/quiz/passage_regression_test.dart
A  test/features/quiz/presentation/completed_quiz_hydration_test.dart
A  test/features/quiz/presentation/completed_quiz_provider_test.dart
A  test/features/quiz/presentation/custom_launch_boundary_test.dart
A  test/features/quiz/presentation/flagged_launch_boundary_test.dart
A  test/features/quiz/presentation/flagged_ui_launch_boundary_test.dart
A  test/features/quiz/presentation/launch_page_disposal_test.dart
D  test/features/quiz/presentation/pages/debrief_page_test.dart
D  test/features/quiz/presentation/pages/debrief_tagging_test.dart
M  test/features/quiz/presentation/pages/flagged_list_page_test.dart
D  test/features/quiz/presentation/pages/practice_picker_page_test.dart
A  test/features/quiz/presentation/practice_pace_refresh_test.dart
A  test/features/quiz/presentation/practice_picker_screen_test.dart
D  test/features/quiz/presentation/practice_review_test.dart
M  test/features/quiz/presentation/question_flag_providers_test.dart
A  test/features/quiz/presentation/quick_launch_boundary_test.dart
M  test/features/quiz/presentation/quiz_controller_test.dart
M  test/features/quiz/presentation/quiz_leave_resume_panel_test.dart
A  test/features/quiz/presentation/quiz_note_boundary_test.dart
A  test/features/quiz/presentation/quiz_note_editor_test.dart
M  test/features/quiz/presentation/quiz_page_chrome_test.dart
M  test/features/quiz/presentation/quiz_page_test.dart
A  test/features/quiz/presentation/quiz_pick_check_test.dart
A  test/features/quiz/presentation/quiz_question_screen_test.dart
A  test/features/quiz/presentation/quiz_question_viewer_test.dart
D  test/features/quiz/presentation/quiz_results_page_test.dart
A  test/features/quiz/presentation/quiz_review_boundary_integration_test.dart
A  test/features/quiz/presentation/quiz_route_coverage_test.dart
A  test/features/quiz/presentation/quiz_session_end_page_test.dart
D  test/features/quiz/presentation/quiz_tab_home_test.dart
D  test/features/quiz/presentation/quiz_tab_nudge_test.dart
A  test/features/quiz/presentation/quiz_tab_screen_test.dart
A  test/features/quiz/presentation/quiz_viewer_route_registration_test.dart
A  test/features/quiz/presentation/review_next_boundary_test.dart
A  test/features/quiz/presentation/session_end_screen_test.dart
D  test/features/quiz/presentation/widgets/length_wheel_test.dart
D  test/features/quiz/presentation/widgets/session_panel_test.dart
M  test/features/quiz/session_start_telemetry_test.dart
M  test/features/roadmap/application/roadmap_controller_test.dart
M  test/features/settings/application/settings_actions_test.dart
A  test/features/settings/application/w4f_trial_label_test.dart
M  test/features/settings/data/settings_repository_test.dart
M  test/features/settings/domain/backup_status_test.dart
M  test/features/settings/domain/delete_account_copy_test.dart
M  test/features/settings/presentation/about_page_test.dart
M  test/features/settings/presentation/account_offline_copy_test.dart
M  test/features/settings/presentation/account_page_test.dart
M  test/features/settings/presentation/backup_offline_copy_test.dart
A  test/features/settings/presentation/carry_over_screen_test.dart
M  test/features/settings/presentation/delete_account_page_test.dart
M  test/features/settings/presentation/exam_page_test.dart
M  test/features/settings/presentation/pro_page_payments_test.dart
M  test/features/settings/presentation/session_building_page_test.dart
M  test/features/settings/presentation/settings_detail_pages_test.dart
M  test/features/settings/presentation/settings_home_page_test.dart
D  test/features/settings/presentation/sheets/name_sheet_test.dart
D  test/features/settings/presentation/sheets/ordering_sheet_test.dart
D  test/features/settings/presentation/sheets/reminder_sheet_test.dart
M  test/features/settings/presentation/sync_reconciliation_gate_test.dart
A  test/features/settings/presentation/w4f_account_test.dart
A  test/features/settings/presentation/w4f_appearance_test.dart
A  test/features/settings/presentation/w4f_backup_test.dart
A  test/features/settings/presentation/w4f_checkout_return_test.dart
A  test/features/settings/presentation/w4f_error_reporting_test.dart
A  test/features/settings/presentation/w4f_exam_test.dart
A  test/features/settings/presentation/w4f_lesson_scope_test.dart
A  test/features/settings/presentation/w4f_name_test.dart
A  test/features/settings/presentation/w4f_pass_warning_test.dart
A  test/features/settings/presentation/w4f_pending_exam_test.dart
A  test/features/settings/presentation/w4f_practice_test.dart
A  test/features/settings/presentation/w4f_pro_states_test.dart
A  test/features/settings/presentation/w4f_pro_test.dart
A  test/features/settings/presentation/w4f_root_states_test.dart
A  test/features/settings/presentation/w4f_screen_states_test.dart
A  test/features/settings/presentation/w4f_upgrade_checkout_test.dart
M  test/features/settings/presentation/whats_included_page_test.dart
M  test/features/shell/app_shell_test.dart
M  test/helpers/pump_app.dart
 M test/tool/content_package_builder_cli_test.dart
M  test/tool/content_package_builder_test.dart
M  test/tool/content_package_verifier_test.dart
 M test/tool/firebase_indexes_layout_test.dart
D  test/tool/progress_boundary_test.dart
M  test/tool/release_e2e_runner_test.dart
M  test/tool/settings_release_guard_test.dart
M  test/tools/lesson_illustration_preview_renderer_test.dart
A  test/tools/lesson_svg_assets_test.dart
A  tool/extract_cse_finale_motion.py
M  tools/build_content_seed/seed_writer.dart
A  tools/check_lesson_svgs.py
A  tools/check_lesson_svgs_render_test.dart
A  tools/check_lesson_svgs_test.py
M  tools/lesson_author/illustration_preview_renderer.dart
M  tools/lesson_author/render_illustration_previews_test.dart
M  tools/release/e2e/runner_support.py
A  tools/svg_fixtures/fail/animation.svg
A  tools/svg_fixtures/fail/css.svg
A  tools/svg_fixtures/fail/doctype.svg
A  tools/svg_fixtures/fail/event.svg
A  tools/svg_fixtures/fail/external-paint.svg
A  tools/svg_fixtures/fail/external.svg
A  tools/svg_fixtures/fail/filter.svg
A  tools/svg_fixtures/fail/ignored-attribute.svg
A  tools/svg_fixtures/fail/ignored-baseline.svg
A  tools/svg_fixtures/fail/ignored-clip-units.svg
A  tools/svg_fixtures/fail/ignored-font-style.svg
A  tools/svg_fixtures/fail/ignored-fr.svg
A  tools/svg_fixtures/fail/inline-css.svg
A  tools/svg_fixtures/fail/malformed.svg
A  tools/svg_fixtures/fail/mask.svg
A  tools/svg_fixtures/fail/nested-svg.svg
A  tools/svg_fixtures/fail/raster.svg
A  tools/svg_fixtures/fail/script.svg
A  tools/svg_fixtures/fail/set.svg
A  tools/svg_fixtures/fail/shadow.svg
A  tools/svg_fixtures/fail/smil.svg
A  tools/svg_fixtures/fail/symbol-viewbox.svg
A  tools/svg_fixtures/fail/unsupported-clip-child.svg
A  tools/svg_fixtures/fail/unsupported.svg
A  tools/svg_fixtures/fail/use-cycle.svg
A  tools/svg_fixtures/fail/use-self.svg
A  tools/svg_fixtures/pass/basic.svg
A  tools/svg_fixtures/pass/use-shared.svg
?? docs/superpowers/plans/pwa-launch/evidence/staging-candidate-r1.md
```

## October 27: full verification after access and payments hardening merges

Assignment: the current lead brief supplies the bounded verification plan. No implementation or product redesign. This section supersedes earlier automated results for this candidate. Earlier release/device limitations remain separate.

- Candidate: `b8b3e8b03882688491b2ced22d5d6168f7d46131`, branch `web/staging-candidate-r1`. Initial working tree clean.
- Policy: `AGENTS.md`, `WORKFLOW.md`, and `SUBAGENTS.md` read using `git show origin/main:<file>` at `64e5757674ccca9eb42e1b63d22df84f788de470`. No fetch or pull.
- Environment: Flutter 3.44.6, Dart 3.12.2, Node v26.10.0, npm 11.19.1, OpenJDK 21 for Functions. Package declares Node 22; this local run used Node 26.
- Completed UTC: 2026-10-27T04:38:51.237650+00:00
- Full raw command logs and exit files: `/tmp/pantas-r1-verification/`.
- No source fixes, dependency changes, generated package rebuild, staging, commit, push, merge, deployment, device launch, or visual acceptance. Only this evidence file remains changed.

### Commands and actual summaries

`flutter test`, exit 0:

```text
11:38 +4880: All tests passed!
```

`flutter analyze lib test tool`, exit 0:

```text
Analyzing 3 items...
No issues found! (ran in 29.2s)
```

`dart format --output=none --set-exit-if-changed lib test tool`, exit 0:

```text
Formatted 1562 files (0 changed) in 3.37 seconds.
```

`dart run tool/check_layering.dart`, exit 0:

```text
Running build hooks...Running build hooks...check_layering: OK
```

`dart run tool/check_no_ai_attribution.dart`, exit 0:

```text
Running build hooks...Running build hooks...check_no_ai_attribution: OK
```

`server_dart/build.sh --check`, exit 0:

```text
generated JS is current
```

`cd functions && npx tsc --noEmit`, exit 0:

```text
(no output)
```

`cd functions && PATH=/opt/homebrew/opt/openjdk@21/bin:$PATH npm test`, exit 0:

```text
ℹ tests 195
ℹ suites 0
ℹ pass 195
ℹ fail 0
ℹ cancelled 0
ℹ skipped 0
ℹ todo 0
ℹ duration_ms 2302.299542
ℹ tests 280
ℹ suites 0
ℹ pass 280
ℹ fail 0
ℹ cancelled 0
ℹ skipped 0
ℹ todo 0
ℹ duration_ms 103675.345583
✔  Script exited successfully (code 0)
```

`flutter build web --release -t lib/main_staging.dart`, exit 0:

```text
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Expected to find fonts for (MaterialIcons, Phosphor, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons, Phosphor). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Compiling lib/main_staging.dart for the Web...                     63.8s
✓ Built build/web
```

`flutter build apk --debug --flavor dev -t lib/main_dev.dart`, exit 0:

```text
Caught exception: Could not start the FSEvents stream: /opt/homebrew/share/flutter/packages/flutter_tools/gradle
Running Gradle task 'assembleDevDebug'...                          31.8s
✓ Built build/app/outputs/flutter-apk/app-dev-debug.apk
```

### Inputs, isolation, and limits

Functions used `CI=true` and `XDG_CONFIG_HOME=/tmp/pantas-r1-verification/cli`. Auth 39099, Firestore 38089, Storage 39199, hub 34449, logging 34509; UI disabled. Ports were checked free before starting. The temporary `firebase.json` emulator configuration was restored byte-for-byte after npm test. The suite CLI also reported its Firestore UI websocket on 9153. No unrelated emulator was stopped.

No native-assets failure occurred. The full Flutter suite passed on its first run; no isolated rerun was necessary.

Nonfatal output: web build reported a missing Cupertino icon font. Android reported that it could not start an FSEvents stream, then completed successfully. Functions emitted metadata lookup warnings. These did not fail their commands. No live payment, production credentials, physical device, protected native-package acceptance, or visual behavior was verified. The exact requested build commands used no additional content key defines.

SHA-256 of material inputs and built artifacts:

```text
7be9c689fc705b9ff04e0fb012e6421798ca11f7f110f7c72f2c8ec92567ff31  assets/seed/content.db
4f42eef66dfd25ff043399f906f6a9ed16d32bfbf14f8cb0aaf749ad2266080c  android/app/google-services.json
540b53f067c49661e33832baf81f54cdee2e556d19c9ea3fb6ae2cfb1f79ae13  pubspec.lock
c1251b2d66505df7c298497a080c158d755a175674b65f973dc8ca8b6c80786d  functions/package-lock.json
d5b21c923d6fb1ac541b4b3d2328e4d107be5141324069d702f4bd8320611e96  build/web/main.dart.js
7e34d5c7be6b967946100623c3de52e23523ab10722fb49e1cdabb5c7971a212  build/app/outputs/flutter-apk/app-dev-debug.apk
```

Local seed and google-services.json stayed ignored and were never staged. No credential values were displayed.

Post-evidence attribution recheck: exit 0, `check_no_ai_attribution: OK`. `git diff --check`: exit 0, no output.

Final `git status --short`:

```text
 M docs/superpowers/plans/pwa-launch/evidence/staging-candidate-r1.md
```
