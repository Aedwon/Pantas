# Update-at-once final scale-back verification

Status: implemented, verified and independently reviewed locally. Local commit
only; no push, merge, deployment, Firebase access, UI change or release acceptance.

Branch: web/update-at-once-r1. Starting HEAD: 054357371.
Policy first retrieved at main 14bc67a994d95d2fa353c7b04715b56da7f2609f.
Remote main advanced concurrently to b8ee42be740bdcf58e8ea2d9426baa99c94bacd2;
AGENTS.md, WORKFLOW.md, SUBAGENTS.md and process-improvement policy are unchanged.
Controlling scope: Aedwon's final SCALE BACK ruling, recorded verbatim in the
Nov 14 final scale-back entry of the PWA launch log. Plan: final amendment in
../plans/2026-11-14-update-at-once.md. Versioned-build plans are superseded.

Code/config/test patch against starting HEAD, excluding documentation:
`git diff HEAD --binary -- lib test tool web .github | shasum -a 256`

```
503f6a2d703ad1ca60ff3bff9e948955da2049c5139e195c0b0c5984be87dd92
```

## Final behavior and version source

Main already stamps the existing Flutter service worker token plus a 12-character
content hash into flutter_bootstrap.js's registerWorker argument. The restored
bootstrap still passes that identity to the unchanged registration path. The
additive PWA bridge captures it as currentVersion, never from a later network
read or worker takeover. Native and old pages lacking the bridge remain no-ops.

Main version.json did not expose that comparable identity. The restored stamper
now adds only pantasBuildVersion to that JSON object, preserving existing fields.
The hash normalizes version metadata and omits its own added field so stamping
twice remains stable. No new layout, inventory, file moves, worker stamps or
bootstrap changes remain against main.

check fetches version.json with cache no-store, compares pantasBuildVersion,
returns available/version, and requests the existing registration's update in
parallel. Worker refresh failures do not hide detection. Version request/JSON
failure or a four-second deadline permits retry at the next safe point. Checks
coalesce only while in flight. Visibility return and five-minute visible ticks
check without reload. The duplicate Dart 30-second poll is removed. Idle Home
background detection alone waits for an app safe-point/lifecycle check to apply.
apply only calls location.reload synchronously. It does not wait for installation,
activate workers, clear caches, unregister workers or alter browser storage.
The older existing PWA updateNow action is preserved exactly from main.

The app still guards first Home appearance, returns to Home, quiz/mock results
and lesson end. Active sessions, onboarding, checkout and input overlays defer.
The local-write/outbox durability barrier and post-wait safety recheck remain.
054357371's coordinator retry/accounting fix remains unchanged: consume a version
only after apply succeeds. No new UI or styling was authored.

## Tests first

Restored main's PWA helper and stamper before writing the new Node regressions.
`node --test test/web/pantas_update.test.mjs test/web/stamp_worker_version.test.mjs`
produced these actual totals before implementation:

```
ℹ tests 13
ℹ pass 3
ℹ fail 10
```

The nine bridge cases failed because pantasUpdate did not exist. The metadata
case failed because pantasBuildVersion was absent. Representative actual errors:

```
TypeError [Error]: Cannot read properties of undefined (reading 'currentVersion')
  actual: { version: '1.0.0', build_number: '4' }
  expected: { version: '1.0.0', build_number: '4', pantasBuildVersion: '213919009-aa32357ca7d4' }
```

The updated Dart browser test also failed against the old promise-based apply:

```
web bridge reads version and invokes synchronous reload apply [E]
TypeError: null: type 'Null' is not a subtype of type 'JSObject'
00:00 +2 -1: Some tests failed.
```

An initial test callback inferred Never instead of void and was corrected before
this behavioral red run. Default Chrome was absent; the installed Playwright
chromium_headless_shell-1248 executable then ran the tests in a fresh Flutter
profile. No screenshots or desktop/browser control were used. Node's obsolete
tool/web/*.test.mjs glob matched nothing after removal; the corrected final
suite command below covers all retained and new Node tests.

## Completed checks

```
node --test test/web/*.test.mjs
ℹ tests 75
ℹ pass 75
ℹ fail 0

dart format --output=none --set-exit-if-changed <21 existing changed Dart files>
Formatted 21 files (0 changed) in 0.03 seconds.

flutter analyze --no-pub lib test
Analyzing 2 items...
No issues found! (ran in 5.2s)

flutter test --no-pub test/core/platform/app_update test/features/lesson/presentation/lesson_page_test.dart
00:03 +45: All tests passed!

flutter test --no-pub --platform chrome --timeout 60s test/core/platform/app_update/update_bridge_web_test.dart
00:00 +3: All tests passed!

flutter test --no-pub --platform chrome --timeout 60s test/core/storage/data/database_opener_web_test.dart
00:00 +5: All tests passed!

dart run tool/checks/design_lint.dart
OK    design-lint: 631 finding(s) match the baseline (19s)

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

git diff --cached --check
<empty>
```

53 focused Dart/Flutter tests passed across VM and browser runs. Browser commands
set CHROME_EXECUTABLE to the existing headless-shell-1248 binary. This task's
Flutter jobs ran sequentially. pgrep identified existing tester processes owned
by other worktrees before starting; those were left alone. The repository checks
retained their existing accepted exceptions (shell-route-push, ACET question
bank gaps, exam-scoped lesson map, typeahead shortcut handling); no baseline or
exception changed.

Independent read-only review at the completed code patch: no remaining must-fix
findings. One unintended whole-file deletion was caught and corrected: main's
147-line browser database tests are restored exactly, only the /b/ additions
are removed. All five restored browser tests pass.

## Production infrastructure equality

The requested command returned no output:

```
git diff origin/main -- web/pantas_sw.js firebase.json firebase.staging.json web/index.html
```

This expanded comparison also returned no output:

```
git diff origin/main -- web/flutter_bootstrap.js docs/deploy-prod.md lib/core/storage/data/database_opener_web.dart test/core/storage/data/database_opener_web_test.dart .github/workflows/ci.yml tool/deploy/staging_web.sh web/README.md
```

The worker, caching, flat hosting layout, Drift worker URL, deploy instructions,
CI and original tests therefore equal main. retain_builds.mjs, its tests,
stamp_update_manifest tests and folder-worker tests are removed. Against main,
only web/pantas_pwa.js and tool/web/stamp_worker_version.mjs differ in the web
and build layer, plus their two Node test files.

## Exact files differing from main

The inventory below includes inherited coordinator/durability work and historical
workstream documents. The absent security-audit report is a newer main-only file,
not a deletion made by this task or included in its commit. Main advanced during
this task; it was not merged into this branch. Inventory captured at main
b8ee42be740bdcf58e8ea2d9426baa99c94bacd2.

```
M	docs/superpowers/decisions/2026-10-19-pwa-launch-log.md
M	docs/superpowers/estimates/velocity-log.md
A	docs/superpowers/plans/2026-11-14-update-at-once.md
A	docs/superpowers/plans/2026-11-14-versioned-web-builds.md
D	docs/superpowers/plans/security-audit/2026-11-14-report.md
A	docs/superpowers/specs/2026-11-14-update-at-once-app.md
A	docs/superpowers/specs/2026-11-14-versioned-web-builds.md
A	docs/superpowers/verification/2026-11-14-update-at-once-app.md
A	docs/superpowers/verification/2026-11-14-update-at-once-scale-back.md
A	docs/superpowers/verification/2026-11-14-versioned-web-builds.md
M	docs/workflow/process-improvement.md
M	lib/app/router.dart
A	lib/app/update_coordinator_provider.dart
A	lib/core/platform/app_update/update_bridge.dart
A	lib/core/platform/app_update/update_bridge_stub.dart
A	lib/core/platform/app_update/update_bridge_web.dart
A	lib/core/platform/app_update/update_coordinator.dart
A	lib/core/platform/app_update/update_overlay_registry.dart
M	lib/core/storage/data/app_database.dart
M	lib/core/sync/engine/local_sync_mutation_recorder.dart
M	lib/core/sync/engine/pending_queue.dart
M	lib/core/ui/components/centered_dialog.dart
M	lib/core/ui/components/pantas_sheet.dart
M	lib/core/ui/web/web_side_drawer.dart
M	lib/core/ui/web/web_side_overlay.dart
M	lib/features/lesson/presentation/lesson_page.dart
A	test/core/platform/app_update/update_bridge_web_test.dart
A	test/core/platform/app_update/update_coordinator_test.dart
A	test/core/platform/app_update/update_durability_test.dart
A	test/core/platform/app_update/update_inline_overlay_test.dart
A	test/core/platform/app_update/update_routing_test.dart
M	test/features/lesson/presentation/lesson_page_test.dart
A	test/web/pantas_update.test.mjs
M	test/web/stamp_worker_version.test.mjs
M	tool/web/stamp_worker_version.mjs
M	web/pantas_pwa.js
```

Not verified: a new release build, real devices, two actual deployments, offline
rollout or production behavior. No release/deployment proof is claimed. The final
user ruling intentionally preserves the production worker's existing limits.
Timer web-update-scale-back: 6 min 59 s measured active/wall before final evidence
and commit; initial context retrieval was not measured.
