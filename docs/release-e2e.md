# Local release E2E

The runner is `tools/release/test_e2e.sh`. It runs six scenarios separately on
one Android target. It starts and resets only Firebase Auth and Firestore
emulators under a temporary `demo-` project. It does not call live services.
There is no browser or host-only execution mode.

Keep these scenarios:

1. Shipping cold start: verifies the supplied encrypted payload hash, installs
   the signed protected package, completes onboarding, reads a shipping lesson,
   and checks that read state survives reconstruction.
2. Quiz state: uses the current custom quiz picker, answers the three fixture
   questions, and checks attempts, review state, review logs, mistakes, and daily
   totals after reconstruction. The old Home quick-quiz entry no longer exists.
3. Mock resume: starts the prepared paper, answers and flags questions, pauses
   through the Flutter lifecycle, reconstructs storage, resumes from the current
   pause screen, and submits the same attempt. This is not process-death proof.
4. Local deletion: creates lesson, quiz, and mock progress through the UI, deletes
   anonymous local data in Settings, and checks retained preferences and content.
5. Firebase round trip: uses production repositories and sync engines to upload
   a bookmark and restore it into an isolated database.
6. Firebase conflict and isolation: reconciles a stale local bookmark update and
   requires read and write denial across two named emulator users.

## Run on Android

The lead must first commit the completed test changes. The runner rejects a dirty
worktree. Keep the accepted protected package unchanged. Load only its existing
bootstrap key using `docs/content-key-access.md`. Never regenerate the package to
make this suite run.

Use the pinned toolchain checked by the runner: Flutter 3.41.9, Dart 3.11.5,
JDK 17, Gradle 8.14, AGP 8.11.1. The Firebase CLI, Python 3, and ADB must already
be available. Start an Android emulator and select its explicit ADB serial.
The Firebase harness uses the Android emulator's `10.0.2.2` host bridge.

Run from the repository root in a shell with the bootstrap variable loaded:

```sh
bash tools/release/test_e2e.sh \
  --candidate b98163bd980eb96d573c1a901a5afbc9bfba9035 \
  --content-sha "$(shasum -a 256 assets/seed/content.db | cut -d ' ' -f 1)" \
  --device emulator-5554
```

Replace the serial with the selected emulator's serial. The runner verifies the
package against the candidate's pinned provenance. It clears the dev app's data
before each scenario. Logs and per-scenario results go under `build/release-e2e/`.
Do not substitute `flutter test integration_test` without the runner's isolation
and compile-time inputs.

## October 30, 2026 adaptation status

Source candidate: `b98163bd980eb96d573c1a901a5afbc9bfba9035`.
Policy read from local `origin/main` at
`d588f68f8be94016724ff0837be284cd4ea5c561`, without fetching.
All six scenarios are retained. No application source, dependencies, runner
provenance checks, or hosted workflows changed. The runner already listed all six
files. The Firebase setup now supplies the expiring Pro claim required by the
current gateway and Firestore rules. Fixture questions now carry lesson tags for
the current practice picker. The fixture supplies its own exam catalog entry
through the existing provider override.

`adb devices -l` listed no targets. Device journeys and Firebase emulator journeys
were not executed. Static and tool-test results are recorded below after final
verification. These checks do not establish release E2E acceptance.

Final commands and actual output, all exit 0:

```text
flutter analyze
No issues found! (ran in 8.0s)
dart format --output=none --set-exit-if-changed lib test integration_test
Formatted 1707 files (0 changed) in 2.00 seconds.
dart run tool/check_layering.dart
check_layering: OK
dart run tool/check_no_ai_attribution.dart
check_no_ai_attribution: OK
flutter test test/tool
00:17 +201: All tests passed!
```

The expiring-claim regression test failed with exit 1 when the expiry field was
removed temporarily. The field was restored before the final analyzer and tests.
Full logs are in ignored `build/release-e2e/r2-static/`. Dependency resolution,
build-runner generation, and the requested content export also completed. The
protected package was not rebuilt. No global tools were installed. No repository
fetch, commit, push, branch switch, deployment, or live-service call occurred.
Independent review and device acceptance remain with the lead.

Files in this handoff:

- `integration_test/release/shipping_cold_start_e2e_test.dart`
- `integration_test/release/quiz_state_e2e_test.dart`
- `integration_test/release/mock_resume_e2e_test.dart`
- `integration_test/release/delete_local_data_e2e_test.dart`
- `integration_test/release/firebase_sync_roundtrip_e2e_test.dart`, retained as staged
- `integration_test/release/firebase_conflict_isolation_e2e_test.dart`, retained as staged
- `integration_test/release/support/firebase_emulator_harness.dart`
- `integration_test/release/support/release_harness.dart`
- `integration_test/release/support/test_content_fixture.dart`
- `integration_test/release/support/fixture_quiz_journey.dart`, new shared UI helper
- `test/tool/release_e2e_firebase_contract_test.dart`
- `test/tool/release_e2e_fixture_test.dart`
- `docs/release-e2e.md`
- `docs/superpowers/decisions/2026-09-04-release-e2e-log.md`

Shared helpers, the existing deletion scenario, and the fixture contract were
updated because their old onboarding, quiz, catalog, and lesson-tag assumptions
also affected the runner's existing scenarios. The runner and its contract were
read and verified but did not need edits.
