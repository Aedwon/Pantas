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
