# B7c: deferred libraries

Implementation candidate: `web/deferred-libs-r1`, base
`afffc9fec738666e94ae96d5888b9857fdbc71a0`, plus the uncommitted B7c patch.
Policy read with `git show origin/main:<file>` at
`44afc369259e599acdfdc6417d808014e578c1fc`. No fetch or pull.
Controlling plan: origin/main `2026-10-19-pwa-launch.md`, B7c, and the lead brief.

## Split and retained libraries

- Settings, account, and Pro: split together behind the web route builder boundary.
  `settings_routes.dart` conditionally exports the web route declarations on
  `dart.library.js_interop`. Those declarations defer `settings_routes_native.dart`.
  Each builder calls `loadLibrary()` before using the existing screen builder.
  This shares one deferred library across the family, including legal screens.
  Subsequent opens reuse Dart's loaded library. Failed loads can retry.
- Native: the conditional export selects the original synchronous route builders.
  The original implementation moved to `settings_routes_native.dart`. Its account
  deletion helper moved unchanged to an eager helper file so the router's existing
  public export does not import the screen library eagerly on web.
- Mock exam: left eager. Import inspection found that the first-session Quiz route
  imports `mock_exam.dart`, which exports `mock_results_providers.dart` and mock
  presentation pages. `mock_results_providers.dart` itself imports
  `presentation/pages/mock_results_route.dart` for `decodeMockResults`. The Quiz
  tab watches `mockResultsProvider` for the last score. Deferring route imports
  alone would retain this eager route dependency. Separating the provider/decoder
  and changing the shared barrel is outside this route-boundary assignment.
- Onboarding, Home, lesson, quiz, and shared providers/types stay eager.
  A recursive import/export check from `main_dev.dart`, selecting the web export
  and excluding deferred edges, found no eager path to the settings screen module,
  settings home, account page, or Pro page. The settings provider barrel has no
  presentation exports. No provider or shared type moved behind a deferred import.

## Routing and states

Paths and redirects remain synchronously declared. `/pro` preserves its URI while
redirecting to `/settings/pro`. `/settings/exam/transfer` keeps its typed-extra
redirect guard. `/paywall` is already retired on this candidate, as asserted by the
existing route tests; it was not added or changed.

The wrapper uses `loadingFor(AsyncLoading<void>())`, the existing W4h delayed
loading shapes, and `StateView.fullScreen` with its existing generic copy and retry.
No new visible text. Page construction happens only after the library loads.

## Test-first evidence

Before implementing loading, the wrapper directly built its page. Both new tests
failed on behavior, not compilation:

```text
00:00 +0 -1: shows loading before building the loaded page [E]
00:00 +0 -2: failed load retries and then opens the page [E]
00:00 +0 -2: Some tests failed.
```

After implementation:

```text
flutter test test/app/deferred_route_test.dart test/app/router_paths_preserved_test.dart test/app/router_settings_test.dart
00:13 +10: All tests passed!
flutter test test/app/deferred_settings_routes_test.dart
00:03 +2: All tests passed!
```

Additional tests compare native/web route paths and redirect presence and open a
web account route with a query parameter, then pop back to the prior page.
The first router run could not compile because generated localization files were
absent. `flutter gen-l10n` completed, then those tests passed. Generated files and
seed files remain unstaged. Build runner completed successfully before testing.

## Final verification

Actual command summaries (all listed successful commands exited 0):

```text
flutter test
18:18 +4817: All tests passed!
flutter test test/app/deferred_settings_routes_test.dart
00:00 +2: All tests passed!
flutter analyze lib test tool
No issues found! (ran in 12.0s)
dart format --output=none --set-exit-if-changed lib test tool
Formatted 1522 files (0 changed) in 3.56 seconds.
dart run tool/check_layering.dart
check_layering: OK
dart run tool/check_no_ai_attribution.dart
check_no_ai_attribution: OK
```

The full suite ran on the completed behavior. Analysis then found five trailing
comma lints in the new route test. Only commas and formatting changed afterward;
that test reran successfully and analysis is clean. The earlier wrapper-test
trailing-comma lint was also corrected. No production source changed after the
full suite. Native route code and the extracted deletion helper were compared
against the base revision and match apart from whitespace and helper imports.

Android build did not pass. Initial runs failed creating/accessing the Gradle
file-hash cache. Creating this worktree's ignored cache directory did not fix the
existing daemon's permission error. A fresh Gradle invocation passed that stage:

```text
GRADLE_OPTS='-Dorg.gradle.daemon=false' flutter build apk --debug --flavor dev -t lib/main_dev.dart
Execution failed for task ':app:processDevDebugGoogleServices'.
> File google-services.json is missing.
BUILD FAILED in 26s
Running Gradle task 'assembleDevDebug'...                          26.9s
Gradle task assembleDevDebug failed with exit code 1
```

No config was copied from another worktree. The missing local Firebase Android
configuration blocks APK verification. This is an unresolved verification failure,
not a passing native build. The lead must supply the dev configuration and rerun
that command. No merge or acceptance is claimed.

Final `git status --short`:

```text
 M lib/app/routes/settings_routes.dart
?? docs/superpowers/plans/pwa-launch/evidence/B7c-deferred-libraries.md
?? lib/app/routes/deferred_route.dart
?? lib/app/routes/settings_account_deletion.dart
?? lib/app/routes/settings_routes_native.dart
?? lib/app/routes/settings_routes_web.dart
?? test/app/deferred_route_test.dart
?? test/app/deferred_settings_routes_test.dart
```

Source identity (SHA-256, excluding this evidence document):

```text
06dfa479aef3dd2a31ae38420754cc67abdf3604fbe5fbd7a8de31aa4efcd38d  lib/app/routes/settings_routes.dart
69ec4c9b5804083525c2619be7ce95fb909c6ee395957f562834f60bc769888c  lib/app/routes/deferred_route.dart
5ef30f9a767bb1c0d840a5268439dd8470bec57c5ce51e801d70f57376fc6687  lib/app/routes/settings_account_deletion.dart
5cb5b0f1221d6a0527c496cbc65a4faf3926267cf6964a492b05717bd721f348  lib/app/routes/settings_routes_native.dart
b96497e6d55f0931aec5ab9e962f02977832a7aa54c3eb1462edab794586791a  lib/app/routes/settings_routes_web.dart
8559341aadeca9eec1f4539750d547495c26c611615b398f570ad45a385c1626  test/app/deferred_route_test.dart
f64ccb8ceb83c1491d90f2ed1dc9909d24f6c7678bf3baf36a05b6344441f16d  test/app/deferred_settings_routes_test.dart
```

Files outside the original route file: the conditional native/web implementations,
shared loading wrapper, eager account-deletion helper, two tests, and this required
evidence file. These implement the route-boundary split and preserve native API
compatibility. No feature providers, payment code, entitlement code, or content
were changed.

## Measurement and remaining acceptance

This worktree has no web entry point. No web size or speed measurements were
attempted. Measure first-load transfer size before and after on the staging
candidate and put the results in B4 evidence. Confirm the actual emitted deferred
chunks there. Service-worker offline delivery after a first visit, browser Back,
real-device web behavior, and visual acceptance remain staging checks.

Independent review and integration belong to the lead. No commit, push, deploy,
or other worktree change was made. The shared `new-design/STATUS.md` is absent in
this tree; its task update remains with the lead and the status-lock owner.

## October 26: merged B7c comparison at 417078bf

This new run supersedes the earlier statement that B7c size was unmeasured. It does
not replace browser transfer or offline acceptance. Policy: origin/main
`44afc369259e599acdfdc6417d808014e578c1fc`. Candidate:
`417078bf8015e50b6b78b0e5026204d680534aaf`; baseline: `9d3141a5`.
The initial candidate working tree was clean. No fetch, pull, staging, commit,
push, deploy, dependencies, or visual changes were made.

Both builds used Flutter 3.44.6 / Dart 3.12.2, engine
`83675ed27633283e7fc296c8bca22e841224c096`, and:

```sh
git worktree add --detach /private/tmp/pantas-b7c-before-9d3141a5 9d3141a5
# In that temporary worktree, after supplying the ignored generated files:
flutter pub get --offline
dart run build_runner build --delete-conflicting-outputs
flutter build web --release -t lib/main_staging.dart --source-maps
# In the assigned candidate worktree:
flutter build web --release -t lib/main_staging.dart --source-maps
# After saving measurements and checking the temporary tree was clean:
git worktree remove /private/tmp/pantas-b7c-before-9d3141a5
```

Actual execution built the candidate first, then the baseline. Existing ignored
`.g.dart`, `.freezed.dart`, and localization outputs were copied into the temporary
worktree before its own code generation. Ignored seed companions were also copied;
the platform-filtered web bundle excludes them. Both measurement builds used the
committed `588610f4184ff762` seed-version constant, so the local native rebuild did
not contaminate the source comparison. The rebuilt native constant was restored
afterward. The baseline worktree was removed successfully.

B8 method: raw file bytes; Python `gzip.compress(data, compresslevel=9, mtime=0)`,
compressing each file separately. Source maps are diagnostics and excluded from
first load. Deferred part files are excluded from the static first-load set for
onboarding/Home/lesson/quiz. Direct entry to a deferred route adds its part.
No browser request timing or transferred-byte measurement is claimed.

| JavaScript payload | Before raw | Before gzip | After raw | After gzip |
|---|---:|---:|---:|---:|
| `main.dart.js` | 6,828,259 | 1,926,780 | 6,705,270 | 1,889,609 |
| `main.dart.js_1.part.js` | absent | absent | 135,941 | 43,133 |
| Main plus all deferred parts | 6,828,259 | 1,926,780 | 6,841,211 | 1,932,742 |

Main savings: **122,989 raw / 37,171 gzip bytes**. Loading the deferred part later
makes the total compiled JavaScript **12,952 raw / 5,962 gzip bytes larger** than
the baseline. One part was emitted, plus its `.map` diagnostic. No other deferred
part files were emitted. Main SHA-256 before:
`b9ceeae07cd2a9e6486f6704de0435fa0c2cf3dce5e0ddad6ac61ffe7d35b393`;
after: `cb2b1c595470099614eec55150a7bddb1175de01d348c06af005345c914d17aa`.
Deferred part SHA-256:
`4c8f106604cd493c981127810de7ceee342b8a3ce19cfab7bd61bafbd51901df`.

### Static first-load set, same B8 inventory

Both AssetManifest representations, FontManifest, the exam catalog, web manifest,
favicon, HTML/bootstrap, SQLite/Drift worker, all Geist/icon/KaTeX fonts, main JS,
and the selected CanvasKit pair. Other renderer variants, source maps, native seed,
and deferred parts are excluded. Dynamic Firebase/auth/App Check scripts, server
responses, headers and cache behavior remain unmeasured.

| Group | Before raw | Before gzip | After raw | After gzip |
|---|---:|---:|---:|---:|
| HTML + bootstrap | 11,475 | 4,591 | 11,475 | 4,589 |
| Main JS | 6,828,259 | 1,926,780 | 6,705,270 | 1,889,609 |
| Chromium CanvasKit pair | 5,846,998 | 2,209,125 | 5,846,998 | 2,209,125 |
| SQLite + Drift worker | 1,176,595 | 494,090 | 1,176,595 | 494,090 |
| Geist, four weights | 510,404 | 241,178 | 510,404 | 241,178 |
| Phosphor + Material icons | 22,924 | 10,797 | 22,924 | 10,797 |
| KaTeX fonts | 640,372 | 370,050 | 640,372 | 370,050 |
| Manifests + catalog + web metadata | 18,627 | 3,883 | 18,627 | 3,883 |

| Renderer configuration | Before raw | Before gzip | After raw | After gzip |
|---|---:|---:|---:|---:|
| Chromium CanvasKit | 15,055,654 | 5,260,494 | 14,932,665 | 5,223,321 |
| Full CanvasKit | 16,524,982 | 5,977,393 | 16,401,993 | 5,940,220 |

Total static first-load savings: **122,989 raw / 37,173 gzip bytes**. The bootstrap
accounts for the extra 2 gzip bytes saved. As in B8, this is a conservative static
budget, not proof of the under-6-MB network target. The full-renderer gzip budget
leaves only 59,780 bytes for all omitted dynamic requests and overhead.

Both builds passed. Both printed the existing missing CupertinoIcons font warning.
The emitted `flutter_service_worker.js` unregisters itself on activation; it does
not contain a cache inventory for the new part. Offline delivery after a first
visit is therefore not established by this build. No service worker change was
made. Real-browser Back/retry/deferred-route behavior, phone/Safari checks, visual
acceptance, Lighthouse, actual staging first/repeat traffic and Welcome timing
remain unverified. Mock remains eager as documented above.

Full local build logs, byte/hash inventories, and the measurement script are in
`/private/tmp/staging-r1-verification/` (`web-before.log`, `web-after.log`,
`before.json`, `after.json`, `measure.py`). The table records the durable results.


## October 27: repeated B7c measurement, exact before and after sources

The whole lead brief was repeated on resumption. Policy read from origin/main:
`3613e243f059de4f4ce5b6f8980c9229f59df933`. Source comparison remains before
`9d3141a5` and after `417078bf8015e50b6b78b0e5026204d680534aaf`.
Flutter 3.44.6 / Dart 3.12.2 and the engine revision match October 26.
The existing evidence edits were reviewed and kept as historical results.
This section records fresh measurements; it supersedes their byte totals for
this run only. No browser traffic measurement is claimed.

B8 method was reused: each selected file's raw bytes and Python
`gzip.compress(data, compresslevel=9, mtime=0)` bytes. The static inventory includes
HTML/bootstrap, main JS, both AssetManifest representations, FontManifest,
exam catalog, web manifest/favicon, SQLite/Drift worker, all Geist/icon/KaTeX fonts,
and one CanvasKit pair. Source maps, other renderer variants, native seed,
and deferred parts are excluded from first load. Direct deferred-route entry
adds its part. Dynamic scripts, server responses, headers and cache behavior
remain excluded and unmeasured.

The assigned branch was never switched. Exact comparison builds:

```sh
# Candidate: preserve the rebuilt local constant, use the committed source for comparison.
cp lib/core/content/content_seed_version.dart /private/tmp/staging-r1-oct27/schema10-content_seed_version.dart
git show HEAD:lib/core/content/content_seed_version.dart > lib/core/content/content_seed_version.dart
flutter build web --release -t lib/main_staging.dart --source-maps
cp /private/tmp/staging-r1-oct27/schema10-content_seed_version.dart lib/core/content/content_seed_version.dart
python3 /private/tmp/staging-r1-oct27/measure.py build/web /private/tmp/staging-r1-oct27/after.json

git worktree add --detach /private/tmp/pantas-b7c-oct27-before 9d3141a5
# In the temporary baseline worktree, supply ignored generated outputs and seed companions.
flutter pub get --offline
dart run build_runner build --delete-conflicting-outputs
flutter build web --release -t lib/main_staging.dart --source-maps
# From the assigned worktree:
python3 /private/tmp/staging-r1-oct27/measure.py /private/tmp/pantas-b7c-oct27-before/build/web /private/tmp/staging-r1-oct27/before.json
git -C /private/tmp/pantas-b7c-oct27-before status --short
git -C /private/tmp/pantas-b7c-oct27-before diff --exit-code
git worktree remove /private/tmp/pantas-b7c-oct27-before
```

Actual preparation created the baseline worktree before the candidate comparison
build. Candidate measurement preceded baseline measurement. Ignored `.g.dart`,
`.freezed.dart`, localization outputs and seed companions were copied for setup.
Baseline code generation ran against its own source. No dependencies were added.
Both comparison builds used the committed `588610f4184ff762` version constant.
A preparatory command briefly copied the rebuilt constant into the baseline;
it was restored from baseline HEAD before code generation or compilation.
An initial measurement invocation pointed at the unbuilt baseline and produced
an empty inventory; it was discarded and rerun against the candidate output.
Neither mistake affects the recorded inventories. The assigned candidate's local
schema-10 constant was restored. Baseline status/diff were clean before successful
worktree removal; no force removal was used.

```text
# Candidate comparison build, exit 0
Compiling lib/main_staging.dart for the Web...                     32.8s
✓ Built build/web
# Baseline comparison build, exit 0
Compiling lib/main_staging.dart for the Web...                     30.9s
✓ Built build/web
```

Both full compilations printed the existing missing CupertinoIcons font warning.
No font changes were made.

| JavaScript payload | Before raw | Before gzip | After raw | After gzip |
|---|---:|---:|---:|---:|
| `main.dart.js` | 6,828,259 | 1,926,780 | 6,705,270 | 1,889,609 |
| `main.dart.js_1.part.js` | absent | absent | 135,941 | 43,133 |
| Main plus all deferred parts | 6,828,259 | 1,926,780 | 6,841,211 | 1,932,742 |

Main saves **122,989 raw / 37,171 gzip bytes**. Loading the deferred part later
makes total compiled JS **12,952 raw / 5,962 gzip bytes larger** than baseline.
The candidate emits exactly one deferred part plus its diagnostic `.map`.
The baseline emits no deferred parts. Main and part hashes match October 26:

- Before main: `b9ceeae07cd2a9e6486f6704de0435fa0c2cf3dce5e0ddad6ac61ffe7d35b393`.
- After main: `cb2b1c595470099614eec55150a7bddb1175de01d348c06af005345c914d17aa`.
- After part: `4c8f106604cd493c981127810de7ceee342b8a3ce19cfab7bd61bafbd51901df`.

| Static first-load group | Before raw | Before gzip | After raw | After gzip |
|---|---:|---:|---:|---:|
| HTML + bootstrap | 11,474 | 4,590 | 11,475 | 4,592 |
| Main JS | 6,828,259 | 1,926,780 | 6,705,270 | 1,889,609 |
| Chromium CanvasKit pair | 5,846,998 | 2,209,125 | 5,846,998 | 2,209,125 |
| SQLite + Drift worker | 1,176,595 | 494,090 | 1,176,595 | 494,090 |
| Geist, four weights | 510,404 | 241,178 | 510,404 | 241,178 |
| Phosphor + Material icons | 22,924 | 10,797 | 22,924 | 10,797 |
| KaTeX fonts | 640,372 | 370,050 | 640,372 | 370,050 |
| Manifests + catalog + web metadata | 18,627 | 3,883 | 18,627 | 3,883 |

| Renderer configuration | Before raw | Before gzip | After raw | After gzip |
|---|---:|---:|---:|---:|
| Chromium CanvasKit | 15,055,653 | 5,260,493 | 14,932,665 | 5,223,324 |
| Full CanvasKit | 16,524,981 | 5,977,392 | 16,401,993 | 5,940,223 |

Static first-load savings: **122,988 raw / 37,169 gzip bytes**. Bootstrap output
accounts for the difference from main-JS savings and the small difference from
October 26 static totals. The full-renderer gzip budget leaves **59,777 bytes**
under decimal 6 MB before omitted requests and overhead. This does not establish
the under-6-MB transferred target. Source maps remain diagnostics only.

Mock remains eager. The generated service worker unregisters itself; deferred
chunk offline delivery remains unverified. Actual staging first/repeat traffic,
Welcome timing, Lighthouse, phone/Safari behavior, browser Back/retry and human
visual acceptance remain unverified. No deploy or UI automation was performed.
Fresh measurement inputs, file hashes, script and build logs are preserved in
`/private/tmp/staging-r1-oct27/` as `before.json`, `after.json`, `measure.py`,
`before-size.log`, `after-size.log`, `web-before.log`, `web-after.log`,
`before-pubget.log` and `before-codegen.log`.
