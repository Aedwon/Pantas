# Versioned web build verification

Status: implemented, independently reviewed and verified locally. No push,
deployment, Firebase operation, main integration or release acceptance.
Branch: web/update-at-once-r1. Base: 46adf8a0f.
Policy main: 05d90fdc4fd7f42af35250a29737a2ad38e03fdd.
Spec: ../specs/2026-11-14-versioned-web-builds.md.
Plan: ../plans/2026-11-14-versioned-web-builds.md.

## Behavior and mechanism

Flutter 3.44.6's `_flutter.loader.load({config: ...})` accepts
`entrypointBaseUrl`, `assetBase`, and `canvasKitBaseUrl`. Confirmed against the
installed SDK loader and https://docs.flutter.dev/platform-integration/web/initialization.
They point respectively at `/b/v/`, `/b/v/`, and `/b/v/canvaskit/`.
Navigation base stays `/`. Drift/WASM use the same running `pantasBuildBase`.
The root index pins helper scripts and its existing font URLs. The root loader
uses that pin, or its own stamped version for a cached legacy flat index.

The stamp preserves the opaque Flutter token plus content-hash identity. It
moves build files into their folder and publishes SHA-256 files.json. Flutter
leaves custom b/ output behind; the stamp removes it before fresh packaging.
Only verified live inventories restore predecessors. Idempotent stamping keeps
the identity and refreshes the small compatible root loader.

The preparation CLI accepts LIVE_ORIGIN then optional build directory. It reads
live metadata and downloads live current plus one predecessor's files.json and
files. It rejects missing inventories, unsafe paths and hash mismatches. It
writes new/current/predecessor identities to metadata and worker and drops older
folder output. The staging script now calls it before its existing deploy step.
That script was inspected, never executed.

First rollout uses absence of a folder-retention list to recognize flat layout,
including flat builds already carrying pantasBuildVersion. It reads Flutter's
published generated RESOURCES map, verifies MD5 hashes, and restores old root
build files. It excludes root control files. Metadata records legacyFlat; worker
configuration records SHA-256 hashes for those exact legacy paths. The worker
caches those verified old files before claiming pages, preserving offline legacy
parts too. The next fresh deployment keeps folder predecessors only and drops
flat paths. Missing legacy inventory stops preparation, never invents a list.

Worker folder fetches are cache-first on exact URLs, without page messages.
Root index/navigation, loader and version metadata are network-first with a
three-second fallback. Only complete SHA-256-verified folders can become the
offline index fallback. Wrong/missing/private/no-store/HTML install bytes reject
installation; retries fetch fresh bytes rather than reusing a poisoned cache.
A changing deployment cannot overwrite the complete offline index with an
uncached build. Activate immediately, retain current plus last two folder caches,
claim pages. Reserved auth/shared paths, other origins, credentials, ranges and
no-store requests bypass handling. Unrelated root paths pass through except the
explicit one-rollout legacy list. Historical shell caches are not guessed from
or erased during migration.

Check compares the running bootstrap identity with no-store version.json.
A four-second deadline covers both fetch and JSON parsing; failures reset the
in-flight check so later safe points retry. Visibility and five-minute checks
never reload. Apply reloads immediately. The coordinator consumes a version only
after successful apply; route, overlay and write-durability checks stay intact.

## Failing-first evidence

Before implementation:

```
node --test tool/web/update_at_once.test.mjs tool/web/stamp_update_manifest.test.mjs
11 tests, 1 pass, 10 fail

node --test tool/web/retain_builds.test.mjs
3 tests, 0 pass, 3 fail

flutter test --no-pub --no-test-assets test/core/platform/app_update/update_coordinator_test.dart
00:00 +13 -1: Some tests failed.
failed apply does not consume the reload attempt
```

The failed-check case already passed before modification. The apply retry case
exposed the actual suppression bug. Unsafe detection remains covered by route,
overlay and delayed-write tests. No claim that every new test had to fail.

Additional red runs reproduced review findings before fixes: auth navigation
caching, stamped legacy flat metadata, root font paths, incomplete install bytes,
index identity/completeness, persistent install poison, slow check deadline,
Flutter's real inline deprecation token, stale b/ output, and legacy unpinned
index loading `/b/undefined/`. Old client-version tests were replaced; redundant
static helper-cache assertions now live in actual packaging inventory coverage.

## Final tests and checks

```
node --test tool/web/*.test.mjs test/web/*.test.mjs
91 tests, 91 pass, 0 fail, 0 canceled, 0 skipped

flutter test --no-pub --concurrency=1 \
  test/core/platform/app_update/update_coordinator_test.dart \
  test/core/platform/app_update/update_durability_test.dart \
  test/core/platform/app_update/update_inline_overlay_test.dart \
  test/core/platform/app_update/update_routing_test.dart
00:04 +22: All tests passed!

flutter test --no-pub --platform chrome --timeout 60s \
  test/core/platform/app_update/update_bridge_web_test.dart
00:00 +2: All tests passed!

flutter test --no-pub --platform chrome --timeout 60s \
  test/core/storage/data/database_opener_web_test.dart
00:01 +6: All tests passed!
```

30 distinct Dart/Flutter tests passed, including the real browser database opener
using the running folder's default URLs. Browser runs used the existing
chromium_headless_shell-1248 executable with Flutter's fresh temporary profile.
Initial Chromium 1193 hung before tests and was stopped; Chromium 1148 could not
load its missing framework. Neither is claimed as a pass. The headless-shell
reruns passed. All launched browsers exited or were stopped. No screenshots.

```
dart format --output=none --set-exit-if-changed <4 changed Dart files>
Formatted 4 files (0 changed)

flutter analyze --no-pub lib test
No issues found! (ran in 7.5s)

dart run tool/checks/design_lint.dart
OK    design-lint: 631 finding(s) match the baseline (24s)

dart run tool/check_layering.dart
check_layering: OK

dart run tool/checks/run_checks.dart
All 9 checks OK, existing accepted findings reported, no baseline change

dart run tool/check_no_ai_attribution.dart
check_no_ai_attribution: OK

git diff --check
<no findings>
```

One import-order analyzer finding in the added browser test was fixed, then the
final analysis above passed. Flutter jobs ran sequentially. Pre-existing tester
PIDs 61320 and 78424 belong to other worktrees and were left alone; no new tester
remained at completion. The full Flutter suite and hosted CI were not run. The
requested focused checks were run locally without uploads.

## Release build and artifact

```
flutter build web --no-pub --release -t lib/main_staging.dart \
  --dart-define=APP_CHECK_WEB_SITE_KEY=dummy-local-verification
Compiling lib/main_staging.dart for the Web... 54.2s
✓ Built build/web

node tool/web/stamp_worker_version.mjs build/web
Build version: 1555920181-1c829df455ae
```

The first release build succeeded but exposed Flutter's inline token comment.
Rebuilding after web fixes exposed persistent custom b/ output. The final build
and stamp above contain one current folder. No seed package was regenerated;
existing ignored local fixtures were used. No secret was loaded.

Build warnings: existing icon-family expectation mentions CupertinoIcons missing
from the available fonts, followed by normal font tree-shaking messages. The
build succeeded. This job makes no visual-acceptance claim.

```
build/web/
  index.html flutter_bootstrap.js version.json pantas_sw.js
  manifest.json icons/ favicon.png og-image.png
  b/1555920181-1c829df455ae/
    main.dart.js main.dart.js_1.part.js main.dart.js_2.part.js main.dart.js_3.part.js
    assets/ canvaskit/ flutter.js flutter_bootstrap.js
    drift_worker.js sqlite3.wasm files.json
    pantas_history.js pantas_pwa.js pantas_splash.js pantas_welcome.js README.md
```

A separate artifact check rehashed all 73 inventory entries, confirmed exactly
one b/ folder, verified index and bootstrap identities, pinned CSS fonts, and
absence of root main.dart.js. The retention tool was tested against local mocks,
not a live hosting origin. The built output is ignored and not committed.

## Review and remaining work

Independent read-only review found auth bypass, flat detection, font URLs,
install validation, offline completeness, legacy offline and install-retry gaps.
Each was fixed and re-reviewed. Final review: no findings, 91 Node tests passed.

Local implementation is complete. Remaining release proof: authorized preparation
against the actual live host, confirming its published legacy inventory, real
consecutive deployment/rollback/offline tests, Android Chrome and iPhone Safari
storage survival through reload, and deployment acceptance. No push, deployment
or Firebase operation occurred. No UI, pricing, content, schema or entitlement
changed. No browser proof here substitutes for real device/deployment proof.

Task source SHA-256 (sorted changed lib/test/tool/web path, NUL, bytes, NUL):
`b9774723622d3cb9825f866965b435345a266d0285597d468c7be1773990b94f`.

## Superseded by final scale-back ruling

November 14: Aedwon withdrew the worker and hosting migration after two read-only
reviews. This document is historical, not the current build or deployment plan.
The final ruling is recorded in the PWA launch log; current evidence is
`docs/superpowers/verification/2026-11-14-update-at-once-scale-back.md`.
