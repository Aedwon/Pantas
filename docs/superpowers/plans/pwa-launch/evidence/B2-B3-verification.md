> The record below describes the first run. The continuation results are appended
> under "Second pass, October 19". Initial missing-asset failures are historical.

# B2/B3 verification record

Candidate: `web/pwa-foundation-r1`, HEAD
`5e6cda4541a80609b27f2784fc2e58d39731a33b`, plus this uncommitted patch.
The lead fetched before dispatch. Local origin/main equals
`89a7d865be7ba7911a6e289d2b3b9711439606f9`, and
origin/integration/new-design-r1 equals HEAD. No fetch was run.
The worktree was clean at startup. No branch switch, git metadata mutation,
commit, push, stash, reset, or rebase was performed.

## Files changed, one line each

- `B2-B3-REPORT.md`: Requested implementor handoff.
- `docs/superpowers/plans/pwa-launch/evidence/B2-B3-verification.md`: File-by-file reasons, commands, actual gate output, and limitations.
- `docs/superpowers/plans/pwa-launch/evidence/B2-B3-wasm-probe.txt`: Verbatim shipped-wasm failure evidence.
- `docs/superpowers/plans/pwa-launch/evidence/B3-encrypted-web-db.md`: Primary-source research and explicit database stop conditions.
- `lib/core/content/bundle/protected_content_installer.dart`: Conditional platform export preserving native imports and public API.
- `lib/core/content/bundle/protected_content_installer_native.dart`: Original implementation moved unchanged behind the platform export.
- `lib/core/content/bundle/protected_content_installer_web.dart`: Explicit failing web boundary for unresolved database support.
- `lib/core/content/bundle/seed_installer.dart`: Conditional platform export preserving native imports and public API.
- `lib/core/content/bundle/seed_installer_native.dart`: Original implementation moved unchanged behind the platform export.
- `lib/core/content/bundle/seed_installer_web.dart`: Explicit failing web boundary for unresolved database support.
- `lib/core/content/content_database_opener.dart`: Conditional platform export preserving native imports and public API.
- `lib/core/content/content_database_opener_native.dart`: Original implementation moved unchanged behind the platform export.
- `lib/core/content/content_database_opener_web.dart`: Explicit failing web boundary for unresolved database support.
- `lib/core/storage/data/database_opener.dart`: Conditional platform export preserving native imports and public API.
- `lib/core/storage/data/database_opener_native.dart`: Original implementation moved unchanged behind the platform export.
- `lib/core/storage/data/database_opener_web.dart`: Explicit failing web boundary for unresolved database support.
- `lib/core/telemetry/firebase_telemetry.dart`: Skip Crashlytics singleton and calls on web; keep Analytics.
- `lib/features/notifications/data/flutter_local_notifications_gateway.dart`: Conditional platform export preserving native imports and public API.
- `lib/features/notifications/data/flutter_local_notifications_gateway_native.dart`: Original implementation moved unchanged behind the platform export.
- `lib/features/notifications/data/web_notifications_gateway.dart`: Reuse inert reminders and app-settings behavior on web.
- `lib/features/paywall/application/paywall_providers.dart`: Select the existing unavailable purchase gateway before constructing RevenueCat.
- `lib/features/paywall/application/trusted_clock.dart`: Use the existing fallback without a MethodChannel on web.
- `lib/features/review_prompt/data/in_app_review_gateway.dart`: Conditional platform export preserving native imports and public API.
- `lib/features/review_prompt/data/in_app_review_gateway_native.dart`: Original implementation moved unchanged behind the platform export.
- `lib/features/review_prompt/data/web_review_gateway.dart`: Unavailable reviews and no-op requests on web.
- `lib/firebase_options_dev.dart`: Named web SDK placeholders and per-flavor Dart defines.
- `lib/firebase_options_prod.dart`: Named web SDK placeholders and per-flavor Dart defines.
- `lib/firebase_options_staging.dart`: Named web SDK placeholders and per-flavor Dart defines.
- `tool/web/drift_worker.dart`: Reproducible worker source using Drift public API.
- `tool/web/probe_encrypted_wasm.cjs`: Reproduce both cipher failures using the shipped wasm.
- `tool/web/probe_encrypted_wasm.dart`: Reproduce both cipher failures using the shipped wasm.
- `web/README.md`: Artifact sources, versions, reproduction, and blocked scope.
- `web/drift_worker.js`: Worker compiled from the locked Drift package.
- `web/favicon.png`: Generated Flutter web scaffold, kept without product design changes.
- `web/icons/Icon-192.png`: Generated Flutter web scaffold, kept without product design changes.
- `web/icons/Icon-512.png`: Generated Flutter web scaffold, kept without product design changes.
- `web/icons/Icon-maskable-192.png`: Generated Flutter web scaffold, kept without product design changes.
- `web/icons/Icon-maskable-512.png`: Generated Flutter web scaffold, kept without product design changes.
- `web/index.html`: Generated Flutter web scaffold, kept without product design changes.
- `web/manifest.json`: Generated Flutter web scaffold, kept without product design changes.
- `web/sqlite3.wasm`: Unmodified locked sqlite3mc release artifact, hash verified.

## Environment

Flutter 3.44.6 stable, framework ee80f08bbf; Dart 3.12.2, macos_arm64.
Node v26.10.0. Locked Drift 2.34.3, sqlite3 3.5.1,
google_sign_in_web 1.1.3, url_launcher_web 2.4.3.
The seed database, manifest, and signature were absent before any edits.
Generated source was restored using build_runner and Flutter localization tools.
No generated Dart file was edited by hand.

## Startup and research commands

Commands ran in the assigned worktree. File reads returned exit 0 except the
missing paths explicitly listed below. Repeated reads used the same commands.
These entries record the policy, research, and acceptance commands. Inline
Python edits and shell heredoc authoring were also run through terminal tools;
their exact bodies remain in the session tool transcript, not reproduced here.
This is not a complete literal shell transcript.

```sh
git show origin/main:AGENTS.md
git show origin/main:SUBAGENTS.md
git show origin/main:WORKFLOW.md
git show origin/main:docs/superpowers/plans/2026-10-19-pwa-launch.md
git show origin/main:docs/superpowers/plans/pwa-launch/evidence/B1-web-inventory.md
git show origin/main:docs/superpowers/decisions/2026-10-19-pwa-launch-log.md
git show origin/main:docs/superpowers/specs/2026-10-19-pwa-launch-design.md
git show origin/main:docs/superpowers/plans/new-design/L3-parallel-map.md
git status --short --branch
git rev-parse HEAD origin/main origin/integration/new-design-r1
git remote -v
```

Read local skill instructions: using-superpowers, executing-plans,
test-driven-development, verification-before-completion, systematic-debugging.
Read branch source and dependency docs before describing their behavior.
The plan, spec, policy, inventory, and decision records were not edited.
The shared status record and lock were not changed; lead update is pending.

Additional inspection failures:

- Reading `lib/features/paywall/data/purchase_gateway.dart` returned exit 1:
  `No such file or directory`. The actual interface is `revenuecat_gateway.dart`.
- Searching the guessed Drift path `lib/src/wasm/database.dart` returned exit 2:
  `No such file or directory`. Read the actual public `lib/wasm.dart` instead.
- `ls -la assets/seed` returned exit 1: `No such file or directory`.
- Reading `assets/seed/content.manifest.json` returned exit 1:
  `No such file or directory`. The preceding credential-access note was read.
- Two guessed upstream paths returned HTTP 404; the versioned wasm build source
  and README were subsequently read from their actual locations.

Primary-source web reads: package 3.5.1 README, release, versioned wasm
README, CMakeLists.txt, sqlite_cfg.h, and os_web.c. Links are in the research note.
No protected-content key was read or displayed.

## Scaffold and generation commands

```sh
flutter build web --release -t lib/main_staging.dart
```

Before B2: exit 1, `This project is not configured for the web.`

```sh
flutter create --platforms=web .
```

Exit 0. Wrote 14 files. Kept only web scaffold files. Restored any non-web tracked
changes from a pre-command byte backup and removed new non-web scaffold files.
No other branch was checked out. Git status was clean before the command.

```sh
curl -fL https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-3.5.1/sqlite3mc.wasm -o web/sqlite3.wasm
shasum -a 256 web/sqlite3.wasm
```

Both exit 0. Hash:
`62a34ec725631c0438e4255ce0c6059099bf8e7fb331e7d4d91a38e075f43a19`.

```sh
dart run build_runner build --delete-conflicting-outputs
```

Exit 0. `Built with build_runner/aot in 24s; wrote 2850 outputs.`

```sh
flutter gen-l10n
```

Exit 0. Used l10n.yaml. This restored the missing generated localizations.

```sh
dart compile js -O2 tool/web/drift_worker.dart -o web/drift_worker.js
```

Exit 0. Initial worker compilation: 381496 JavaScript characters.
Final worker command, after removing source maps:

```sh
dart compile js --no-source-maps -O2 tool/web/drift_worker.dart -o web/drift_worker.js
```

Exit 0. `Compiled 14,900,789 input bytes (9,820,525 characters source) to
381,454 characters JavaScript in 1.68 seconds`. Removed compiler intermediates
from web/. Source and locked package versions are recorded in web/README.md.

## Exploratory encryption commands and reversals

The following exploratory implementation files were subsequently removed. They
are not delivered as working functionality. No successful result here is web
application acceptance.

```sh
npm install --prefix /tmp/pantas-b2-b3-node --no-audit --no-fund fake-indexeddb@6.2.4
```

Exit 1, EPERM opening the default npm cache. No system ownership was changed.

```sh
NODE_PATH=/tmp/pantas-b2-b3-node/node_modules node --test test/web/database_keys_test.cjs
```

First exit 1: missing fake-indexeddb. Then, after the next install, exit 1 with
0 passed and 3 failed because the key-vault implementation did not exist yet.
After implementation: exit 0, 3 passed, 0 failed. Tests covered wrapped storage,
non-extractable wrapping key, concurrent initialization, and corrupted records.
Both the implementation and tests were removed after engine incompatibility.

```sh
npm install --cache /tmp/pantas-b2-b3-npm-cache --prefix /tmp/pantas-b2-b3-node --no-audit --no-fund fake-indexeddb@6.2.4
```

Exit 0, added one package outside the application. No app dependency changed.

```sh
dart run tool/web/check_database_cipher.dart
```

Exploratory executions: exit 254 before the helper existed; exit 255 when a
schema-dependent version query preceded key setup; exit 255 for the native
custom memory VFS encryption rejection. After removing that unsupported native
custom-VFS test, exit 0: `PASS: encrypted bytes, reopen, wrong-key refusal`.
The helper and exploratory checker were removed. This was native evidence only.

```sh
dart compile js -O2 tool/web/encrypted_drift_worker.dart -o web/encrypted_drift_worker.dart.js
```

Exit 0, 382469 JavaScript characters. Removed after the engine stop condition.

```sh
dart compile js tool/web/check_wasm_cipher.dart -o build/check_wasm_cipher.js
node tool/web/check_wasm_cipher.cjs
```

Compiler exit 0. Runtime exit 1, first for SQLCipher unknown, then for
ChaCha20 key setup: `Encryption is not supported by the VFS.`
The unsupported implementation was removed. The final research-only reproducer
below replaces it.

```sh
dart compile js tool/web/probe_encrypted_wasm.dart -o build/probe_encrypted_wasm.js
node tool/web/probe_encrypted_wasm.cjs
```

Both exit 0. The probe catches and prints both actual failures. It does not
assert encryption acceptance. Exact output:

```
Compiled 13,627,014 input bytes (8,546,750 characters source) to 316,147 characters JavaScript in 0.88 seconds
sqlcipher: SqliteException(1): while executing, Cipher 'sqlcipher' unknown., SQL logic error (code 1)
  Causing statement: PRAGMA cipher = 'sqlcipher';, parameters: 
chacha20: SqliteException(1): while executing, Setting key failed. Encryption is not supported by the VFS., SQL logic error (code 1)
  Causing statement: PRAGMA key = "x'abababababababababababababababababababababababababababababababab'";, parameters: 
```

A Node WebAssembly export inspection returned exit 0 and found:

```
Cipher and VFS exports: [
  { name: 'dart_sqlite3_register_vfs', kind: 'function' },
  { name: 'dart_sqlite3_unregister_vfs', kind: 'function' }
]
```

## Final required gates

The full Flutter suite was attempted. It stopped before discovering or running
test cases because the asset bundle could not build. No case pass/fail counts
were emitted, so none are invented. All its failure output is included below.
The web build also fails on the missing asset. Wasm dry-run compilation succeeded;
that is not a successful release bundle or a runtime smoke check.

### `flutter analyze`

Exit 1. Actual output:

```text
Analyzing Pantas-wt-pwa-foundation-r1...                        

   info • 'onReorder' is deprecated and shouldn't be used. Use the onReorderItem callback instead. The onReorderItem callback adjusts the newIndex parameter for a removed item at the oldIndex. This feature was deprecated after v3.41.0-0.0.pre. Try replacing the use of the deprecated member with the replacement • lib/features/lesson/presentation/widgets/bookmarks_sheet.dart:238:21 • deprecated_member_use
warning • The asset file 'assets/seed/content.db' doesn't exist. Try creating the file or fixing the path to the file • pubspec.yaml:109:7 • asset_does_not_exist
warning • The asset file 'assets/seed/content.manifest.json' doesn't exist. Try creating the file or fixing the path to the file • pubspec.yaml:110:7 • asset_does_not_exist
warning • The asset file 'assets/seed/content.manifest.sig' doesn't exist. Try creating the file or fixing the path to the file • pubspec.yaml:111:7 • asset_does_not_exist

4 issues found. (ran in 4.2s)

```

### `flutter test`

Exit 1. Actual output:

```text
Error detected in pubspec.yaml:
No file or variants found for asset: assets/seed/content.db.

Error: Failed to build asset bundle

```

### `flutter build web --release -t lib/main_staging.dart`

Final rerun exit 1, after source edits stopped. Actual output:

```text
Compiling lib/main_staging.dart for the Web...                  
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Error detected in pubspec.yaml:
No file or variants found for asset: assets/seed/content.db.

Target web_release_bundle failed: Exception: Failed to bundle asset files.
#0      copyAssets (package:flutter_tools/src/build_system/targets/assets.dart:61:5)
<asynchronous suspension>
#1      WebReleaseBundle.build (package:flutter_tools/src/build_system/targets/web.dart:615:29)
<asynchronous suspension>
#2      _BuildInstance._invokeInternal (package:flutter_tools/src/build_system/build_system.dart:937:9)
<asynchronous suspension>
#3      Future.wait.<anonymous closure> (dart:async/future.dart:546:21)
<asynchronous suspension>
#4      _BuildInstance.invokeTarget (package:flutter_tools/src/build_system/build_system.dart:875:32)
<asynchronous suspension>
#5      FlutterBuildSystem.build (package:flutter_tools/src/build_system/build_system.dart:684:16)
<asynchronous suspension>
#6      WebBuilder.buildWeb (package:flutter_tools/src/web/compile.dart:107:34)
<asynchronous suspension>
#7      BuildWebCommand.runCommand (package:flutter_tools/src/commands/build_web.dart:293:5)
<asynchronous suspension>
#8      FlutterCommand.run.<anonymous closure> (package:flutter_tools/src/runner/flutter_command.dart:1630:27)
<asynchronous suspension>
#9      AppContext.run.<anonymous closure> (package:flutter_tools/src/base/context.dart:154:19)
<asynchronous suspension>
#10     CommandRunner.runCommand (package:args/command_runner.dart:212:13)
<asynchronous suspension>
#11     FlutterCommandRunner.runCommand.<anonymous closure> (package:flutter_tools/src/runner/flutter_command_runner.dart:496:9)
<asynchronous suspension>
#12     AppContext.run.<anonymous closure> (package:flutter_tools/src/base/context.dart:154:19)
<asynchronous suspension>
#13     FlutterCommandRunner.runCommand (package:flutter_tools/src/runner/flutter_command_runner.dart:431:5)
<asynchronous suspension>
#14     FlutterCommandRunner.run.<anonymous closure> (package:flutter_tools/src/runner/flutter_command_runner.dart:307:33)
<asynchronous suspension>
#15     run.<anonymous closure>.<anonymous closure> (package:flutter_tools/runner.dart:104:11)
<asynchronous suspension>
#16     AppContext.run.<anonymous closure> (package:flutter_tools/src/base/context.dart:154:19)
<asynchronous suspension>
#17     main (package:flutter_tools/executable.dart:103:3)
<asynchronous suspension>

Compiling lib/main_staging.dart for the Web...                     24.8s
Error: Failed to compile application for the Web.

```

### `dart format --output=none --set-exit-if-changed lib test`

Exit 0. Actual output:

```text
Formatted 1468 files (0 changed) in 1.55 seconds.

```

### `dart run tool/check_layering.dart`

Exit 0. Actual output:

```text
Running build hooks...Running build hooks...check_layering: OK

```

### `dart run tool/check_no_ai_attribution.dart`

Exit 0. Actual output:

```text
Running build hooks...Running build hooks...check_no_ai_attribution: OK

```

## Identity and limitations

All six moved native files were compared byte-for-byte with `git show HEAD:<old
path>` and matched exactly. `git diff --check` returned exit 0. The Firebase
Android blocks were retained. Application screens and auth behavior were not
changed. No generated Dart source was edited by hand.

The existing deprecation in the bookmark screen was confirmed in HEAD. It was
not corrected as unrelated work. No baseline warning was suppressed, asset path
removed, package rebuilt, or test weakened to produce a passing gate.

B2 is incomplete: web platform files exist and Firebase placeholders are explicit,
but no release bundle or configured staging runtime passed. B3 is partial:
platform guards exist, while database encryption/content setup and Google web
sign-in remain blocked. No browser/device verification, deployment, independent
security review, integration, or production acceptance was performed.


## Final reference drift

The final read-only identity check reported:

```
5e6cda4541a80609b27f2784fc2e58d39731a33b
6801eb10b5938c4e615e176e5fe2507ea76a68bb
5e6cda4541a80609b27f2784fc2e58d39731a33b
```

HEAD and integration are unchanged. origin/main changed externally from startup
89a7d865 to 6801eb10 during this run. This agent did not fetch.
Implementation had already stopped; no code changes followed discovery of drift.
`git diff 89a7d865be7ba7911a6e289d2b3b9711439606f9 6801eb10b5938c4e615e176e5fe2507ea76a68bb -- AGENTS.md WORKFLOW.md SUBAGENTS.md`
returned exit 0 with no output, confirming the three policy documents are unchanged.
`git show --no-patch --format='%H %s' 6801eb10b5938c4e615e176e5fe2507ea76a68bb`
returned exit 0 and identified the new lead decision commit.

`git diff --check` and `dart format --output=none --set-exit-if-changed lib test tool/web`
returned exit 0. The latter reported `Formatted 1470 files (0 changed) in 1.74 seconds.`
The origin/main movement needs the lead's reconciliation; no merge was attempted.

## Second pass, October 19

Source: web/pwa-foundation-r1, HEAD 5e6cda4541a80609b27f2784fc2e58d39731a33b.
The original B2/B3 dirty patch was present and preserved at resumption. The lead
provided origin/main 6801eb10 and integration 5e6cda45. No fetch was performed.
Another process advanced origin/main to 7cc0a80c6c1d667ef9e5ca0658cd67ba1674b2eb
while this run was active. HEAD and integration did not move. The policy files
are identical across that main-reference change. The later Firebase record
assigns actual config insertion to the lead after this pass. Placeholders stay.

No git metadata was modified. No commit, push, merge, reset, or package
regeneration occurred. No production content key was read or injected into a
build. The exact source content and dirty-file identities are recorded in
B2-B3-patch-sha256.txt. Asset, worker, lockfile, and unchanged-native comparisons
are in B2-B3-identities.txt. The native files match their original HEAD bytes.

Environment: Flutter 3.44.6, Dart 3.12.2, Node v26.10.0. Dependencies remain
locked at sqlite3 3.5.1 and Drift 2.34.3. The browser API package is already
locked through Flutter plugins; no app dependency was added. The probe-only
fake-indexeddb 6.2.4 package was installed under /tmp with a task-local npm cache.

### Continuation files and reasons

- lib/core/storage/data/database_opener_web.dart: encrypted Drift IndexedDB opener,
  upstream encryption VFS adapter, random wrapped key record, single-owner Web
  Lock, authenticated startup, close and failure cleanup.
- lib/core/content/content_database_opener_web.dart,
  lib/core/content/bundle/protected_content_installer_web.dart,
  lib/core/content/bundle/seed_installer_web.dart: preserve stopped behavior and
  report the bootstrap-secret stop condition accurately.
- test/tool/notifications_boundary_test.dart: move the sole allowed plugin
  importer to the unchanged native implementation created by the platform split.
  The export and web implementation are still forbidden from importing plugins.
  This test file was necessary to verify the assigned gateway boundary.
- tool/web/probe_encrypted_wasm.dart and probe_encrypted_wasm.cjs: cross VFS,
  default-selection, registration-order, URI, direct, and shim experiments.
- tool/web/probe_browser_host.cjs: synthetic IndexedDB, OPFS, Web Crypto, and Web
  Locks host for the real Dart VFS and opener code. Explicit completion guard.
- tool/web/verify_web_database.dart: actual app schema and encrypted persistence,
  non-extractable key record, tamper refusal, recovery, and owner-exclusion checks.
- web/README.md: current setup, scope, limit, and probe reproduction instructions.
- B2-B3-REPORT.md and this evidence directory: requested updated handoff, research,
  verbatim outputs, source and asset identities.

The scaffold, worker, Firebase placeholders, platform exports, telemetry,
notifications, reviews, purchases, and clock changes from the first run remain.
No Google sign-in UI, production configuration, server gating, content bundle,
schema, generated source, or shared status was changed by this continuation.

### Checks on the continuation

Commands were executed directly in the assigned worktree. Full raw outputs are
preserved beside this file, not truncated to successful lines.

- flutter analyze: exit 1; one existing deprecation outside the changed code.
- flutter build web --release -t lib/main_staging.dart: exit 0.
- dart format --output=none --set-exit-if-changed lib test tool/web: exit 0.
- dart run tool/check_layering.dart: exit 0.
- dart run tool/check_no_ai_attribution.dart: exit 0.
- git diff --check: exit 0.
- dart compile js tool/web/verify_web_database.dart -o build/verify_web_database.js,
  then PANTAS_PROBE_SCRIPT=verify_web_database.js node tool/web/probe_browser_host.cjs:
  exit 0. The real app opener runs in Node with synthetic browser storage adapters.
- Ordinary sqlite3.wasm substituted using PANTAS_PROBE_WASM: expected exit 1,
  rejected before any plaintext database opens.

Full Flutter test result: INCOMPLETE. The command was flutter test --reporter
expanded. It reached 3,969 passes, 1 failed boundary test, and 1 unfinished roadmap
property test. The log stopped progressing at 13:14. After 40:29 total, the run
was interrupted through its own exec session with Ctrl-C. The exec exit was 130.
The log reports the property test as did not complete and includes cleanup errors
caused by cancellation. This is not a full-suite pass. No full rerun was attempted.

The boundary check used the pre-split importer filename. It was corrected to allow
only the unchanged native implementation. The focused rerun has 4 passes and 0
failures. The roadmap test and engine were not changed. The VM suite exercises
the unchanged native conditional paths. The separate Node probe exercises the
final web opener. Full-suite acceptance remains blocked by the incomplete run.

Analyzer output:

```text
Resolving dependencies...
Downloading packages...
  _fe_analyzer_shared 93.0.0 (109.0.0 available)
  _flutterfire_internals 1.3.76 (1.3.78 available)
  analyzer 10.0.1 (14.5.0 available)
  app_settings 8.0.3 (9.0.1 available)
  build 4.0.7 (5.0.0 available)
  build_config 1.3.2 (1.4.0 available)
  build_daemon 4.1.1 (4.1.7 available)
  build_runner 2.15.1 (2.17.1 available)
  built_collection 5.1.1 (5.1.2 available)
  built_value 8.12.6 (8.13.0 available)
  cached_network_image 3.4.1 (4.0.4 available)
  cached_network_image_platform_interface 4.1.1 (5.0.3 available)
  cached_network_image_web 1.3.1 (2.0.3 available)
  cli_util 0.4.2 (0.6.0 available)
  clock 1.1.2 (1.1.3 available)
  cloud_firestore 6.8.0 (7.0.0 available)
  cloud_firestore_platform_interface 8.0.6 (8.0.8 available)
  cloud_firestore_web 5.7.2 (5.7.4 available)
  cloud_functions 6.3.6 (7.0.0 available)
  cloud_functions_platform_interface 6.0.6 (6.1.0 available)
  cloud_functions_web 5.1.12 (5.1.14 available)
  code_assets 1.0.0 (2.1.0 available)
  dart_style 3.1.7 (3.1.14 available)
  dbus 0.7.12 (0.8.0 available)
  dio 5.11.0 (5.11.1 available)
  dio_web_adapter 2.1.2 (2.2.2 available)
  drift 2.34.3 (2.35.2 available)
  drift_dev 2.34.0 (2.35.1 available)
  equatable 2.1.0 (3.0.0 available)
  firebase_analytics 12.4.6 (13.0.0 available)
  firebase_analytics_platform_interface 6.0.6 (6.0.8 available)
  firebase_analytics_web 0.6.1+12 (0.6.2+14 available)
  firebase_app_check 0.4.6 (0.5.0 available)
  firebase_app_check_platform_interface 0.4.2 (0.5.0+2 available)
  firebase_app_check_web 0.2.6 (0.3.0+2 available)
  firebase_auth 6.5.7 (7.0.0 available)
  firebase_auth_platform_interface 9.0.6 (9.1.1 available)
  firebase_auth_web 6.2.6 (6.3.1 available)
  firebase_core 4.13.0 (5.0.0 available)
  firebase_core_platform_interface 8.1.0 (8.1.1 available)
  firebase_core_web 3.10.0 (4.0.0 available)
  firebase_crashlytics 5.2.7 (6.0.0 available)
  firebase_crashlytics_platform_interface 3.8.27 (3.9.1 available)
  firebase_messaging 16.5.0 (17.0.0 available)
  firebase_messaging_platform_interface 4.9.3 (4.11.0 available)
  firebase_messaging_web 4.2.4 (4.3.0 available)
  firebase_remote_config 6.5.6 (7.0.0 available)
  firebase_remote_config_platform_interface 3.0.6 (3.0.8 available)
  firebase_remote_config_web 1.10.13 (1.10.15 available)
  firebase_storage 13.4.6 (14.0.0 available)
  firebase_storage_platform_interface 6.0.6 (6.0.8 available)
  firebase_storage_web 3.11.12 (3.11.14 available)
  flutter_cache_manager 3.4.1 (3.4.5 available)
  flutter_local_notifications 22.3.0 (22.3.2 available)
  flutter_local_notifications_linux 8.0.1 (8.0.2 available)
  flutter_riverpod 2.6.1 (3.4.3 available)
  flutter_secure_storage 10.3.1 (11.2.0 available)
  flutter_secure_storage_darwin 0.3.2 (0.4.3 available)
  flutter_secure_storage_linux 3.0.2 (3.0.3 available)
  flutter_secure_storage_platform_interface 2.0.3 (2.1.1 available)
  flutter_svg 2.2.4 (2.3.0 available)
  freezed 3.2.5 (4.0.3 available)
  glob 2.1.3 (2.2.0 available)
  go_router 17.5.0 (18.1.0 available)
  google_sign_in_android 7.2.11 (7.2.18 available)
  google_sign_in_ios 6.3.0 (6.3.8 available)
  hooks 1.0.3 (2.2.0 available)
  intl 0.20.2 (0.20.3 available)
  io 1.0.5 (1.1.0 available)
  jni 1.0.0 (1.1.0 available)
  jni_flutter 1.0.1 (1.0.4+1 available)
  json_annotation 4.9.0 (4.12.0 available)
  json_serializable 6.11.4 (6.14.1 available)
  matcher 0.12.19 (0.12.20 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  meta 1.18.0 (1.19.0 available)
  mime 2.0.0 (2.1.0 available)
  native_toolchain_c 0.17.6 (0.19.5 available)
  objective_c 9.3.0 (9.6.2 available)
  octo_image 2.1.0 (2.1.2 available)
  package_config 2.2.0 (3.0.0 available)
  path_provider_linux 2.2.1 (2.2.2 available)
  path_provider_platform_interface 2.1.2 (2.1.3 available)
  petitparser 7.0.2 (7.1.0 available)
  platform 3.1.6 (3.2.0 available)
  pool 1.5.2 (1.5.3 available)
  process 5.0.5 (5.0.6 available)
  pub_semver 2.2.0 (2.2.1 available)
  pubspec_parse 1.5.0 (1.6.0 available)
  purchases_flutter 10.8.0 (10.16.0 available)
  qr 3.0.2 (4.0.0 available)
  record_use 0.6.0 (1.1.1 available)
  riverpod 2.6.1 (3.4.3 available)
  shelf 1.4.2 (1.4.3 available)
  sign_in_with_apple 8.1.0 (8.2.0 available)
  source_gen 4.2.4 (4.3.1 available)
  sqflite 2.4.2+1 (2.4.4+2 available)
  sqflite_android 2.4.2+3 (2.4.4+1 available)
  sqflite_common 2.5.7 (2.5.14 available)
  sqflite_darwin 2.4.2 (2.4.4+1 available)
  sqflite_platform_interface 2.4.0 (2.4.2 available)
  sqlite3 3.5.1 (3.7.1 available)
  sqlparser 0.44.5 (0.45.0 available)
  stack_trace 1.12.1 (1.12.2 available)
  stream_transform 2.1.1 (2.1.2 available)
  synchronized 3.4.0+1 (3.5.0 available)
  test_api 0.7.11 (0.7.15 available)
  timezone 0.11.1 (0.11.2 available)
  url_launcher 6.3.2 (6.3.3 available)
  url_launcher_android 6.3.30 (6.3.33 available)
  url_launcher_ios 6.4.1 (6.4.2 available)
  url_launcher_linux 3.2.2 (3.2.3 available)
  url_launcher_macos 3.2.5 (3.2.6 available)
  url_launcher_windows 3.1.5 (3.1.6 available)
  vector_graphics 1.2.0 (1.2.3 available)
  vector_graphics_compiler 1.2.1 (1.3.2 available)
  vector_math 2.2.0 (2.4.3 available)
  very_good_analysis 6.0.0 (11.0.0 available)
  vm_service 15.2.0 (15.4.0 available)
  webdriver 3.1.0 (3.2.0 available)
  xml 6.6.1 (7.1.0 available)
  yaml 3.1.3 (3.1.4 available)
Got dependencies!
122 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Analyzing Pantas-wt-pwa-foundation-r1...                        

   info • 'onReorder' is deprecated and shouldn't be used. Use the onReorderItem callback instead. The onReorderItem callback adjusts the newIndex parameter for a removed item at the oldIndex. This feature was deprecated after v3.41.0-0.0.pre. Try replacing the use of the deprecated member with the replacement • lib/features/lesson/presentation/widgets/bookmarks_sheet.dart:238:21 • deprecated_member_use

1 issue found. (ran in 2.4s)
```

Focused boundary result:

```text
00:00 +0: loading /Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/test/tool/notifications_boundary_test.dart
00:00 +0: notifications domain files do not import framework or plugin packages
00:00 +1: only flutter local notifications gateway imports plugin packages
00:00 +2: notifications files do not import firebase messaging
00:00 +3: pubspec includes local notification dependencies only
00:00 +4: All tests passed!
```

Initial full-suite failure, verbatim:

```text
07:11 +3780 -1: /Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/test/tool/notifications_boundary_test.dart: only flutter local notifications gateway imports plugin packages [E]
  Expected: empty
    Actual: [
              'lib/features/notifications/data/flutter_local_notifications_gateway_native.dart'
            ]
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tool/notifications_boundary_test.dart 39:5     main.<fn>
```

### Acceptance limits

The encrypted path uses the supported upstream wasm and VFS shim, without a
custom engine. It uses IndexedDB on the main thread and permits one active
study-database owner. A second tab is refused. Web Locks and Web Crypto must be
available. No unencrypted or in-memory student-data fallback exists. OPFS and
shared-worker integration are not delivered.

Content remains stopped under the explicit user condition: native startup
requires the pinned bootstrap secret to decrypt the signed SQLCipher package
before rekeying. That secret cannot be kept secret in a compiled web app.
No initializeDatabase seed import or stored-version skip was implemented.
The native manifest, signature, digest, chronology, and rekey checks are unchanged.

No browser, physical phone, staging sign-in, service-worker/offline test,
independent security review, or lead acceptance is claimed. Firebase placeholders
and the Google button remain as directed. Shared status and final acceptance
belong to the lead. No deployment occurred.

### Full-run interruption and finalization output, verbatim

```text
unhandled error during finalization of test:
/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/test/features/roadmap/domain/coverage_property_test.dart
TestDeviceException(Shell subprocess terminated by ^C (SIGINT, -2).)
#0      FlutterTesterTestDevice.finished (package:flutter_tools/src/test/flutter_tester_device.dart:255:5)
<asynchronous suspension>
#1      FlutterTesterTestDevice.kill (package:flutter_tools/src/test/flutter_tester_device.dart:237:5)
<asynchronous suspension>
#2      FlutterPlatform._startTest.<anonymous closure> (package:flutter_tools/src/test/flutter_platform.dart:690:9)
<asynchronous suspension>
#3      FlutterPlatform._startTest.finalize (package:flutter_tools/src/test/flutter_platform.dart:592:11)
<asynchronous suspension>
#4      asyncGuard.<anonymous closure> (package:flutter_tools/src/base/async_guard.dart:108:24)
<asynchronous suspension>

unhandled error during finalization of test:
/Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/test/features/roadmap/domain/coverage_property_test.dart
PathNotFoundException: Deletion failed, path = '/var/folders/9h/5j2x1ypd5fs605k0g0tt058h0000gn/T/flutter_tools.zeuT5g/flutter_test_listener.16Jnbg' (OS Error: No such file or directory, errno = 2)
#0      _Directory._deleteSync (dart:io/directory_impl.dart:216:7)
#1      FileSystemEntity.deleteSync (dart:io/file_system_entity.dart:425:7)
#2      ForwardingFileSystemEntity.deleteSync (package:file/src/forwarding/forwarding_file_system_entity.dart:70:16)
#3      ErrorHandlingDirectory.deleteSync.<anonymous closure> (package:flutter_tools/src/base/error_handling_io.dart:715:22)
#4      _runSync (package:flutter_tools/src/base/error_handling_io.dart:1116:16)
#5      ErrorHandlingDirectory.deleteSync (package:flutter_tools/src/base/error_handling_io.dart:714:12)
#6      FlutterPlatform._createListenerDart.<anonymous closure> (package:flutter_tools/src/test/flutter_platform.dart:787:15)
#7      FlutterPlatform._startTest.finalize (package:flutter_tools/src/test/flutter_platform.dart:592:26)
<asynchronous suspension>
#8      asyncGuard.<anonymous closure> (package:flutter_tools/src/base/async_guard.dart:108:24)
<asynchronous suspension>

40:29 +3969 -1: /Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/test/features/roadmap/domain/coverage_property_test.dart: following the plan covers everything before review-only days - did not complete [E]
40:29 +3969 -1: Some tests failed.

Failing tests:
  /Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/test/features/roadmap/domain/coverage_property_test.dart: following the plan covers everything before review-only days (did not complete)
  /Users/aedwon/Documents/Projects/Pantas-wt-pwa-foundation-r1/test/tool/notifications_boundary_test.dart: only flutter local notifications gateway imports plugin packages
```

Final release build output:

```text
Try `flutter pub outdated` for more information.
Compiling lib/main_staging.dart for the Web...                  
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Expected to find fonts for (MaterialIcons, Phosphor, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons, Phosphor). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 9244 bytes (99.4% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Font asset "Phosphor.ttf" was tree-shaken, reducing it from 488636 to 8836 bytes (98.2% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib/main_staging.dart for the Web...                     35.5s
✓ Built build/web
```

Final formatting output:

```text
Formatted 1471 files (0 changed) in 1.47 seconds.
```

Final source manifest SHA-256: `c48d2d75c928ffb5d88a5408cefdf34e184ef8445afe1951586131185b9b517e`.
