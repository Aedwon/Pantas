# Update-at-once app coordinator verification

Status: implemented, tested and independently reviewed locally. No integration,
push, deployment, Firebase operation or release acceptance performed.

Policy: main 9b449c022becf81e2e7ad15d9fcaf42061183879.
Code base: 4e61f0e74f24974280431c8b263adcaa7fdcf480.
Branch: web/update-at-once-r1.
Approved scope: ../specs/2026-11-14-update-at-once-app.md.
Plan: ../plans/2026-11-14-update-at-once.md.

## Safe points and durability

- Router-delegate settled matches cover startup's first Home appearance, web
  Home and phone Home-tab returns. An empty delegate during boot is not read.
- Quiz debrief/all and completed mock results are allowed. The reader signals
  its existing ending after the frame rebuild starts its final position save.
  Reader reentry cancels a pending ending check.
- All other paths defer, including active quiz/mock, reader, onboarding and
  checkout. Root, web-shell and phone-branch observers track PopupRoutes.
  Actual inline sheets, drawers and dialogs register visibility separately.
- At a safe point, await tracked full database transactions, mutation-recorder
  prelude and local outbox enqueue operations. Drain executor writes through an
  exclusive plain SELECT 1, the same flush mechanism as existing browser
  durable writes. Recheck route and overlay safety after waiting. No network
  sync wait, storage deletion, key change or package regeneration.
- While JS activation waits, hold browser input and routing at the safe point.
  Release on failure. Reserve each detected version once before apply. Existing
  client telemetry receives failures tagged update.apply.
- Poll every 30 seconds to consume JS's cached five-minute checks and visibility
  results while Home stays open. Also check on resume and safe-route changes.
  Native bridge returns no update and performs no apply operation.

## Test evidence

Behavioral red run, before coordinator implementation, using its empty skeleton:
`flutter test --no-pub --no-test-assets test/core/platform/app_update/update_coordinator_test.dart`

```
00:00 +1 -9: Some tests failed.
```

The native no-op passed. Nine tests failed because apply was absent. Additional
regression proofs: disabling the durability barrier produced two failures;
disabling actual inline-modal registration produced four failures; restoring
normal redirect evaluation during activation produced one routing failure.
The actual reader-ending hook test passed with a fake bridge and real database.

Final VM command, run as one Flutter job with concurrency 1:

```sh
flutter test --no-pub --concurrency=1 \
  test/core/platform/app_update/update_coordinator_test.dart \
  test/core/platform/app_update/update_durability_test.dart \
  test/core/platform/app_update/update_inline_overlay_test.dart \
  test/core/platform/app_update/update_routing_test.dart \
  test/app/router_paths_preserved_test.dart \
  test/app/router_tab_bar_test.dart \
  test/app/lesson_route_web_placement_test.dart \
  test/app/web_routes_above_lesson_test.dart \
  test/features/quiz/presentation/quiz_session_end_page_test.dart \
  test/features/lesson/presentation/lesson_page_test.dart \
  test/features/home/presentation/home_tab_test.dart \
  test/core/ui/components/pantas_sheet_test.dart \
  test/features/home/presentation/web/home_web_overlay_motion_test.dart \
  test/core/sync/pending_queue_test.dart \
  test/core/sync/local_sync_mutation_recorder_test.dart \
  test/core/sync/sync_outbox_promoter_test.dart \
  test/core/ui/components/centered_dialog_ds_test.dart \
  test/core/ui/components/centered_dialog_escape_test.dart
```

```
00:20 +205: All tests passed!
```

Then, using an existing Chromium executable and a fresh headless test profile:
`flutter test --no-pub --platform chrome test/core/platform/app_update/update_bridge_web_test.dart`

```
00:00 +0: web bridge reads version and holds input through activation
00:00 +1: web bridge releases input when activation fails
00:00 +2: All tests passed!
```

207 distinct tests passed, including 24 new tests. The new tests cover actual
router boot and safe-point binding, gate refresh during activation, actual
inline-modal lifecycle, an in-flight transaction plus real local outbox enqueue,
late local enqueue, version throttling, failures, native no-op and browser JS
interop/input release. No app screenshot capture occurred.

## Static checks

```
dart format --output=none --set-exit-if-changed <21 changed Dart files>
Formatted 21 files (0 changed)

flutter analyze --no-pub lib test
No issues found! (ran in 5.3s)

dart run tool/checks/design_lint.dart
OK    design-lint: 631 finding(s) match the baseline (20s)

dart run tool/check_layering.dart
check_layering: OK

dart run tool/check_no_ai_attribution.dart
check_no_ai_attribution: OK

git diff --check
<no findings>
```

`dart run tool/checks/run_checks.dart` also exited 0: all nine checks report OK.
Its existing accepted findings remain reported, including unavailable ACET
content. No baseline was raised.

## Review, environment and limits

Independent read-only review found three issues: inline modals bypassed navigator
observers; asynchronous activation allowed input/navigation; and refresh during
activation could evaluate ordinary redirects. All were corrected and reviewed
again. Final review: no remaining findings. Reviewer ran no Flutter jobs.

Two pre-existing flutter_tester processes, PIDs 61320 and 78424, belonged to other
worktrees and were three to four days old. They were inspected and left alone.
All jobs in this task ran sequentially. Final VM suite used concurrency 1.

Initial test startup could not find assets/seed/content.db. Asset-free coordinator
checks ran with --no-test-assets. A later asset-free lesson test hit missing
ink_sparkle.frag, so final widget checks used a normal asset bundle. Existing
local test fixtures were copied from Pantas-wt-guardrails-l1/assets/seed without
regeneration. They remain ignored and are not committed. No secret was loaded.
Both setup failures were corrected before the final green run.

The database tests establish ordering and persisted local rows in an in-memory
SQLite database. They do not prove browser IndexedDB/OPFS durability across a
real reload. Browser tests exercise the Dart bridge with a fake JS API. Live
service-worker activation and deployed-version storage preservation remain the
web job's/integration proof, not a claim made by this bounded app-side job.
The full Flutter suite, release builds and staging/prod journeys were not run.

## Source identity and changed files

SHA-256 of sorted changed lib/test path, NUL, bytes, NUL:
`cff869378d096f3b044b4d293be5c9e53fd1dd5ebc902c72f1d7cf94a3096abd`.

- `lib/app/router.dart`
- `lib/app/update_coordinator_provider.dart`
- `lib/core/platform/app_update/update_bridge.dart`
- `lib/core/platform/app_update/update_bridge_stub.dart`
- `lib/core/platform/app_update/update_bridge_web.dart`
- `lib/core/platform/app_update/update_coordinator.dart`
- `lib/core/platform/app_update/update_overlay_registry.dart`
- `lib/core/storage/data/app_database.dart`
- `lib/core/sync/engine/local_sync_mutation_recorder.dart`
- `lib/core/sync/engine/pending_queue.dart`
- `lib/core/ui/components/centered_dialog.dart`
- `lib/core/ui/components/pantas_sheet.dart`
- `lib/core/ui/web/web_side_drawer.dart`
- `lib/core/ui/web/web_side_overlay.dart`
- `lib/features/lesson/presentation/lesson_page.dart`
- `test/core/platform/app_update/update_bridge_web_test.dart`
- `test/core/platform/app_update/update_coordinator_test.dart`
- `test/core/platform/app_update/update_durability_test.dart`
- `test/core/platform/app_update/update_inline_overlay_test.dart`
- `test/core/platform/app_update/update_routing_test.dart`
- `test/features/lesson/presentation/lesson_page_test.dart`

Documentation also changes the approved task spec, plan, this verification record,
the launch log and the velocity log. Component changes add lifecycle registration
only. CenteredDialog's existing build body is preserved in _build. No wording,
layout, styling, prompt, banner or screen was added or changed.

## November 14 follow-up: inline quiz completion

Bounded authorized correction on web/update-at-once-r1, starting HEAD
107b4a5b9df7cb306f272b8016696d1f5a4afd4b. Current policy retrieved from
main 3966e4774d051876ac14664baeaae9a7ddd018e5. User request recorded verbatim
in the inline quiz completion entry of the PWA launch log; plan amendment in
2026-11-14-update-at-once.md. App-side logic only, no visible UI change.

The shared quiz controller signals completion after publishing QuizComplete.
This covers inline, reviews, new questions, practice and other ordinary quiz
origins, all of which share next(). The shared quiz session ending page and
mock results page signal completion after their first frame, including restored
debriefs and both local/server mock flows. Loading/running quiz states and both
mock start routes clear completion; route changes also clear it.

quizEnded checks immediately. Repeated completion does not invalidate a pending
durability barrier. Session ownership guards prevent delayed completion or
queued results-page callbacks from marking a later session/route safe. Existing
route safe points, overlays, disposal, write barriers and per-version retry
behavior remain. No service worker, hosting, storage schema or UI rendering changes.

### Red proofs

`flutter test --no-pub --concurrency=1 test/features/quiz/presentation/quiz_controller_test.dart --plain-name 'inline QuizComplete'`

```
Expected: <1>
  Actual: <0>
Completion must check immediately
00:00 +0 -1: Some tests failed.
```

The test invokes real startInline/answer/next against a fake bridge, including
unsafe question/reveal checks and restart on the same URL. Mocked launch, answer
and completion storage boundaries reuse existing controller test fixtures.

Independent review's duplicate-completion regression failed before correction:
`flutter test --no-pub --concurrency=1 test/core/platform/app_update/update_coordinator_test.dart --plain-name 'repeated quiz completion'`

```
Expected: <1>
  Actual: <0>
00:00 +0 -1: Some tests failed.
```

The delayed-completion tests also failed before ownership guards:
`flutter test --no-pub --concurrency=1 test/features/quiz/presentation/quiz_controller_test.dart --plain-name 'late quiz completion'`

```
Expected: <0>
  Actual: <1>
00:00 +0 -2: Some tests failed.
```

These cover navigation to a lesson and replacement quiz. An initial broad run
then exposed one fixture error: replacement start() reused the same persisted
session ID and produced QuizFailure. The fixture now uses the existing inline
launch mock for replacement and still requires QuizRunning, preserving the
new-session safety assertion. No production behavior was weakened to pass it.

Final verification evidence and reviewed source identity follow below.

The actual MockResultsRoute widget regression schedules its completion, then
changes route or starts another session before its post-frame callback. Before
the revision guard it failed:

`flutter test --no-pub --concurrency=1 test/core/platform/app_update/update_quiz_results_test.dart`

```
Expected: <0>
  Actual: <1>
00:00 +1 -2: Some tests failed.
```

The positive control signals from an unsafe run URL, proving completion does not
depend on results-route matching. Both callbacks now verify quizRevision. The
same revision advances on route changes and new sessions. Independent final
source review found no remaining findings after all three corrections.

Changed implementation files: coordinator, quiz controller, quiz session end
page, mock results route, local mock start route and server mock route. Changed
test files: coordinator test, quiz controller test and new results widget test.
Documentation changes: this evidence, task plan, PWA launch log, velocity log,
and process-improvement entry for the staging defect.

No new live staging proof, browser/device run, full repository Flutter suite,
build, deployment or Firebase access is claimed by this follow-up. Requested
focused suites and affected mock suites use the existing local fixtures; no
content package regeneration or secret loading occurred.

Exact follow-up file inventory:

- lib/core/platform/app_update/update_coordinator.dart
- lib/features/quiz/presentation/quiz_controller.dart
- lib/features/quiz/presentation/quiz_session_end_page.dart
- lib/features/mock_exam/presentation/pages/mock_results_route.dart
- lib/features/mock_exam/presentation/pages/mock_start_route.dart
- lib/features/mock_exam/presentation/pages/server_mock_route.dart
- test/core/platform/app_update/update_coordinator_test.dart
- test/core/platform/app_update/update_quiz_results_test.dart
- test/features/quiz/presentation/quiz_controller_test.dart
- docs/superpowers/plans/2026-11-14-update-at-once.md
- docs/superpowers/decisions/2026-10-19-pwa-launch-log.md
- docs/superpowers/estimates/velocity-log.md
- docs/superpowers/verification/2026-11-14-update-at-once-app.md
- docs/workflow/process-improvement.md

Final sorted lib/test path, NUL, bytes, NUL SHA-256:
`88df33160365650269e78f88d6811a70c5524ecbd35f81e73ebf67bf734d7f58`.
The results widget test received formatting only after it ran. Analysis also
found one missing trailing comma in the controller test, corrected after the
broad suite. Both edits preserve compiled semantics. A fresh 37-test focused
run and clean analysis then verified the final bytes. Other lib/test bytes
were final before the combined suite began. Existing unrelated tester processes
belonged to other worktrees and were left alone. This task's Flutter jobs were
serialized.

### Final follow-up checks

All commands below exited 0:

```sh
flutter test --no-pub --concurrency=1 test/core/platform/app_update test/features/quiz test/features/mock_exam/presentation test/features/mock_exam/application
```

```
05:31 +1941: All tests passed!
```

After trailing-comma/format-only corrections:

```sh
flutter test --no-pub --concurrency=1 test/core/platform/app_update test/features/quiz/presentation/quiz_controller_test.dart
```

```
00:07 +37: All tests passed!

flutter analyze --no-pub lib test
No issues found! (ran in 4.3s)

dart format --output=none --set-exit-if-changed <9 changed Dart files>
Formatted 9 files (0 changed)

dart run tool/checks/design_lint.dart
OK    design-lint: 631 finding(s) match the baseline (38s)

dart run tool/check_layering.dart
check_layering: OK

dart run tool/checks/run_checks.dart
OK    shell-route-push
OK    sync-mutations-typed-read
OK    mock-blueprint-topics
OK    bold-stem
OK    lesson-list-exam-scope
OK    design-token-literals
OK    custom-subject-tiers
OK    letter-shortcut-gate
OK    legal-text-drafting

dart run tool/check_no_ai_attribution.dart
check_no_ai_attribution: OK

git diff --check
<no findings>
```

The nine repository checks retain their existing accepted exceptions; no
baseline or exception was changed. Design/layering checks preceded only
trailing-comma/format-only test edits. Final source review: no findings.

Follow-up status: implemented, independently reviewed and verified locally.
Timers measured 14 min 51 s plus 52 s, total measured active 15 min 43 s.
Policy reading, timer gap and final recording/commit are unmeasured.
Saved only on the assigned local branch. No push, merge, deployment, Firebase
access, visible UI change or live staging acceptance is claimed.
