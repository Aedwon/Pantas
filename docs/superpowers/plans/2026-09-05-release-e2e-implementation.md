# Pantas Release E2E Implementation Plan

> **For ChatGPT Web workers:** Follow the approved Release E2E design at `docs/superpowers/specs/2026-09-05-release-e2e-design.md`. Use test-driven development for test infrastructure, systematic debugging for every unexpected failure, and verification-before-completion before any success handback. Do not change production application behavior.

**Goal:** Implement the approved six-journey Release E2E suite against production candidate `0f69e79c9a13daaf7198eae62706f09dd9822ab5`, using the exact approved shipping content and the real Pantas storage/auth/Firestore/sync paths, then independently review and run the complete suite three times from isolated state.

**Architecture:** Keep all new behavior in the approved E2E surface. A fail-closed shell runner validates candidate/content/toolchain/device/emulator provenance, prepares isolated state, and runs six Android integration-test journeys. Dart support code supplies a deterministic tiny fixture and reconstruction/polling helpers but reaches content through the existing export document shape, `writeContentSeed`, `SeedInstaller`, and the production database opener/provider wiring. Firebase journeys use Auth + Firestore emulators under a `demo-` project and the real Firebase Auth/Firestore gateways, production sync runtime, and current `firestore.rules`. Production source is treated as immutable evidence.

**Tech stack:** Flutter 3.41.9, Dart/`integration_test`, Riverpod, Drift/SQLite, Android/ADB, JDK 17, Gradle 8.14, AGP 8.11.1, Firebase CLI Auth + Firestore emulators, shell runner, focused Dart tool tests.

---

## Fixed release inputs and hard boundaries

- Production candidate under test: `0f69e79c9a13daaf7198eae62706f09dd9822ab5`.
- Documentation base / Web branch starting point: `ab3f1355e385f9afc120b79bf0ac85f3f8610260`.
- Approved shipping content SHA-256: `eb3a9da425b80a51331cce74694ef014c3372392194bacbd60ba145db5ea2a45`.
- Tracked content prefix: `eb3a9da425b80a51`.
- Public runner contract:
  `tools/release/test_e2e.sh --candidate <40-char-sha> --content-sha <64-char-sha256> --device <adb-serial>`.
- Do not bake the release candidate/content SHA into reusable defaults.
- Do not change `lib/`, Android production behavior/configuration, production dependencies, or any other product-code surface.
- Allowed implementation surface only:
  - `integration_test/release/`
  - `tools/release/test_e2e.sh`
  - `tools/release/e2e/`
  - focused `test/tool/` Release-E2E tests
  - Release-E2E docs
  - deletion of only the dormant `integration` job from `.github/workflows/main.yml`
- Existing `jobs.ci` in `.github/workflows/main.yml` must remain byte-for-byte semantically unchanged.
- No hosted replacement device/emulator CI.
- No AAB build, Play upload, production Firebase acceptance, Play Billing/RevenueCat lifecycle, Play Integrity, production App Check, Google Sign-In, named-account deletion/export, Functions emulator, true Android process death, physical-device accessibility, or notification/OEM/reboot/time-zone acceptance.
- If a stable production test identifier/seam/change is required, or a scenario exposes a product defect, stop that path and publish a concrete blocker/defect handoff. Do not edit production code in this program.

## Exact production interfaces the suite must exercise

Content and bootstrap:
- `assets/seed/content.db` — exact shipping database; Scenario 1 must hash these bytes and never regenerate/substitute them.
- `lib/core/content/content_seed_version.dart` — tracked digest prefix.
- `tools/build_content_export/build_content_export.dart` — canonical production export document shape.
- `tools/build_content_seed/seed_writer.dart` — canonical `writeContentSeed({required File inputJson, required File outputDb})`.
- `lib/core/content/bundle/seed_installer.dart` — `SeedInstaller.install(...)`; constructor already supports `AssetBytesLoader` and `DestinationFileResolver`.
- `lib/core/content/content_database_opener.dart` — `contentDbFileName` and `openContentDatabase()`.
- `lib/core/content/content.dart` — `contentDatabaseProvider` and `bootstrapContentOverrides(...)`.
- `lib/app/bootstrap.dart` — production order installs the seed before RevenueCat/sync.

Navigation and journeys:
- `lib/app/router.dart` — production router and the canonical routes:
  - `/onboarding`
  - `/quiz/...` and `/quiz/results/:attemptId`
  - `/quiz/mock/start`
  - `/quiz/mock/resume/:attemptId` via `MockStartRoute.resume(...)`
  - `/mock/results/:attemptId`
  - Settings route and existing account/local-data actions.
- Existing route/onboarding tests include `test/app/router_onboarding_completion_test.dart`, `test/app/router_redirect_test.dart`, `test/app/study_route_test.dart`, and `test/app/router_mock_panel_test.dart`.
- Mock persistence/lifecycle production logic remains in `lib/features/mock_exam/` and `lib/app/sync_runtime_bootstrap.dart`; the E2E test must drive `AppLifecycleState.paused` through Flutter binding rather than call persistence internals directly.

Storage and deletion:
- `lib/core/storage/storage.dart` and existing Drift repositories are the persistence assertion surface.
- `lib/core/sync/local_state_wiper.dart` / existing Settings deletion wiring are the deletion behavior under test.
- Device preferences and content DB are retained evidence; covered local progress tables are deletion evidence.

Firebase/sync:
- `firestore.rules` — actual user/generation rules, including active/staging generation and per-user row access.
- `lib/app/firebase_bootstrap.dart` and `lib/app/auth_bootstrap.dart` — production Firebase/Auth composition.
- `lib/app/sync_runtime_bootstrap.dart` — `bootstrapSyncRuntime(...)` and `buildConfiguredSyncRuntime(...)`; default production wiring constructs `FirebaseFirestoreGateway`, `FirebaseSyncFunctionsGateway`, and `FirebaseSyncClaimGateway`, while injectable parameters are available for bounded test composition.
- `lib/core/sync/firestore/firebase_firestore_gateway.dart` — production Firestore data gateway.
- `lib/core/auth/` Firebase auth gateway — production Auth gateway used by auth bootstrap.
- `lib/core/sync/runtime/production_sync_runtime_engine.dart`, generation repository, active-context store, full-push/full-pull, and reconciliation code are the production sync path.
- Existing security-rules evidence includes `functions/test/firestore-sync-rules.rules.mjs`.
- V1 Firebase E2E uses only Auth + Firestore emulators under a unique `demo-...` project. Functions remain outside scope; do not simulate them to claim Functions coverage.

---

## Worker dependency and file-ownership map

The orchestrator integrates all worker branches into `web/release-e2e-r1`. Workers must not edit outside their ownership. Shared foundations are merged before scenario workers start. If a later worker needs a shared-support change, it must publish the exact need instead of editing another worker's owned file.

| Phase | Worker task | Exclusive write ownership | Depends on |
| --- | --- | --- | --- |
| 1A | Runner + CI contract | `tools/release/test_e2e.sh`, `tools/release/e2e/**`, `test/tool/release_e2e_runner_test.dart`, `.github/workflows/main.yml` | plan commit |
| 1B | Dart fixture + release harness | `integration_test/release/support/test_content_fixture.dart`, `integration_test/release/support/test_content_seed.dart`, `integration_test/release/support/release_harness.dart`, `test/tool/release_e2e_fixture_test.dart` | plan commit |
| 2A | Shipping cold-start journey | `integration_test/release/shipping_cold_start_e2e_test.dart` | 1A + 1B merged |
| 2B | Quiz + anonymous deletion journeys | `integration_test/release/quiz_state_e2e_test.dart`, `integration_test/release/delete_local_data_e2e_test.dart` | 1A + 1B merged |
| 2C | Mock interruption/resume journey | `integration_test/release/mock_resume_e2e_test.dart` | 1A + 1B merged |
| 2D | Firebase sync/conflict journeys | `integration_test/release/firebase_sync_roundtrip_e2e_test.dart`, `integration_test/release/firebase_conflict_isolation_e2e_test.dart`, `integration_test/release/support/firebase_emulator_harness.dart`, `test/tool/release_e2e_firebase_contract_test.dart` | 1A + 1B merged |
| 3 | Integration hardening | only explicitly assigned E2E support/runner files after a concrete failing scenario proves the need | all Phase 2 merged |
| 4 | Independent review | read-only review handback; no implementation ownership | implementation verification complete |

Parallelism:
- Run 1A and 1B in parallel because their files are disjoint.
- After both are independently verified and integrated, scenario implementation ownership for 2A–2D may proceed in parallel because files are disjoint and shared foundations are read-only.
- Android/Firebase execution against a shared selected target or shared emulator ports must be serialized. Parallel scenario execution is allowed only when each worker has a separately isolated Android target and emulator environment.
- Serialize any shared-foundation correction after a worker publishes a concrete failing need.
- Reviewer has no implementation ownership.

---

### Task 1A: Implement the fail-closed runner and remove only dormant integration CI

**Files:**
- Create: `test/tool/release_e2e_runner_test.dart`
- Create: `tools/release/test_e2e.sh`
- Create helpers only as needed under `tools/release/e2e/`
- Modify: `.github/workflows/main.yml` — delete only `jobs.integration`

**RED**
1. Write focused contract tests that invoke the runner/helper surface in temporary/fake environments and prove it rejects:
   - missing/extra/invalid arguments;
   - non-40-character candidate SHA;
   - non-64-character content SHA;
   - candidate mismatch / dirty source;
   - shipping content hash mismatch;
   - missing/wrong Flutter, JDK, Gradle/AGP expectation;
   - missing Firebase CLI/ADB;
   - absent/ambiguous/unauthorized device target;
   - non-`demo-` Firebase project IDs;
   - production credential/service indicators;
   - port collision or emulator isolation failure;
   - cleanup/diagnostic/summary failure.
2. Add a static workflow assertion that `jobs.ci` remains present/unchanged in structure and `jobs.integration` is absent.
3. Run:
   `flutter test test/tool/release_e2e_runner_test.dart`
4. Confirm failures are from the unimplemented runner contract, not test syntax.

**GREEN**
1. Implement `tools/release/test_e2e.sh` with strict shell mode and explicit `--candidate`, `--content-sha`, `--device` parsing.
2. Reuse/parallel the pinned release-toolchain checks from `tools/release/android/release.sh` without changing that production release script.
3. Verify the checked-out branch contains candidate `0f69...` as production parent while allowing only approved E2E/docs/CI diffs from it. Fail on any other path.
4. Hash exact `assets/seed/content.db`; require complete caller-supplied hash and require tracked `contentSeedVersion` to match the digest prefix.
5. Require explicit ADB serial and verify it is one online Android target.
6. Allocate/check isolated Auth/Firestore emulator ports, require an ephemeral `demo-...` project ID, and reject production project/service/credential configuration.
7. Provide bounded predicate polling helpers; never use arbitrary sleeps.
8. Provide deterministic cleanup and textual failure diagnostics with redaction. Generated DBs/logs/diagnostics must remain ignored.
9. Run all six scenario test files and produce a machine-readable/text summary with per-scenario outcome + runtime and total runtime.
10. Delete only the dormant `integration` job from `.github/workflows/main.yml`. Do not add a replacement job.

**GREEN verification**
- `flutter test test/tool/release_e2e_runner_test.dart`
- Parse `.github/workflows/main.yml` with the repository-available YAML parser.
- `git diff --check`
- `git diff --name-only 0f69e79c9a13daaf7198eae62706f09dd9822ab5...HEAD` must contain only this worker's approved files plus pre-existing Release-E2E docs.
- Commit one reviewable runner/CI commit and push normally.

### Task 1B: Implement deterministic content fixture and release harness

**Files:**
- Create: `integration_test/release/support/test_content_fixture.dart`
- Create: `integration_test/release/support/test_content_seed.dart`
- Create: `integration_test/release/support/release_harness.dart`
- Create: `test/tool/release_e2e_fixture_test.dart`

**RED**
1. Define one minimal deterministic fixture source containing enough exam/subject/topic/lesson/questions/mock blueprint/mock exam data for Scenarios 2–4.
2. Contract-test that the fixture is represented in the same document keys/shapes consumed by the production export/seed pipeline and that no direct SQLite row seeding API exists in the helper.
3. Contract-test a temporary fixture round trip:
   fixture source → production export-shaped JSON → `writeContentSeed` → `SeedInstaller` using its existing injected byte/destination seams → production opener/provider path.
4. Contract-test reconstruction helpers close/dispose and reopen app/user/content databases rather than preserving in-memory objects.
5. Contract-test bounded predicate polling with a deadline and useful timeout diagnostics.
6. Run:
   `flutter test test/tool/release_e2e_fixture_test.dart`
7. Confirm expected RED failures.

**GREEN**
1. Implement only test-side fixture serialization and helpers.
2. Import/call `tools/build_content_seed/seed_writer.dart` `writeContentSeed`; do not duplicate its parsing or hand-build SQLite.
3. Use `SeedInstaller.install` for installation and the production `contentDbFileName`/opener/provider composition for consumption. Any inability to use the real opener without production change is a STOP condition to report, not permission to change `lib/`.
4. Implement release harness helpers for:
   - production `App`/router bootstrap with existing provider overrides only;
   - onboarding completion through UI;
   - exact DB/app reconstruction;
   - repository-based persistence assertions;
   - bounded `waitUntil(predicate, deadline, diagnostics)`;
   - deterministic cleanup/disposal.
5. Keep fixture IDs stable and human-readable so scenario assertions are deterministic.
6. No screenshots/video.

**GREEN verification**
- `flutter test test/tool/release_e2e_fixture_test.dart`
- relevant existing content tests:
  `flutter test test/core/content/bundle/seed_installer_test.dart test/core/content/content_providers_test.dart test/core/content/content_seed_version_test.dart`
- `git diff --check`
- commit one foundation commit and push normally.

### Task 2A: Shipping cold start and offline learning

**File:** `integration_test/release/shipping_cold_start_e2e_test.dart`

**Journey**
1. Assert on-device/test-visible provenance corresponds to caller candidate and exact shipping asset SHA; never regenerate shipping DB.
2. Start from clean local app state with network-dependent services unavailable/rejected by runner.
3. Launch production app/router path, complete onboarding through UI, open a real lesson from the shipping database, mark it read through production UI.
4. Dispose/reconstruct app + user/content database state.
5. Reopen and prove lesson-read state persists while shipping content remains readable offline.

**RED/GREEN**
- Write the journey first and run only this scenario through the runner's targeted internal scenario helper.
- Expected RED must identify missing test-side wiring or a product defect.
- Add only scenario-local/test-support use; no product changes.
- Rerun to GREEN.

**Verification**
- Scenario passes from clean isolated state twice during worker verification.
- Run relevant existing onboarding/content/lesson-progress tests.
- `git diff --check`; commit/push one scenario commit.

### Task 2B: Quiz learning state + anonymous local-data deletion

**Files:**
- `integration_test/release/quiz_state_e2e_test.dart`
- `integration_test/release/delete_local_data_e2e_test.dart`

**Quiz journey**
1. Install the deterministic fixture through Task 1B's production seed path.
2. Complete a quiz through production navigation/UI.
3. Reach production results/debrief.
4. Assert attempt, review/mistake state, and progress via production repositories/DB.
5. Reconstruct app/database and prove the same persisted state remains.

**Deletion journey**
1. Establish meaningful local progress using the same real journey surfaces.
2. Enter Settings and invoke the existing anonymous/local-data deletion UI.
3. Prove covered local progress is removed.
4. Prove retained device preferences and content database remain available.
5. Keep claims explicitly anonymous/local only.

**RED/GREEN**
- Add one journey at a time; run it before adding any test-side adaptation.
- If deletion or persistence differs from approved behavior because of production code, stop with a defect handoff.
- No direct SQL seeding of content.

**Verification**
- Both scenarios pass independently from isolated state.
- Run relevant quiz, lesson/progress, Settings/local-state-wiper tests.
- `git diff --check`; commit/push.

### Task 2C: Mock interruption and production Resume route

**File:** `integration_test/release/mock_resume_e2e_test.dart`

**Journey**
1. Install deterministic fixture via production seed path.
2. Start mock through production `/quiz/mock/start` flow.
3. Answer questions, flag at least one item, advance position, and establish timing state.
4. Trigger a real Flutter lifecycle pause using test binding (`AppLifecycleState.paused`), not direct controller persistence methods.
5. Use bounded polling against persisted state; no sleep.
6. Dispose/reconstruct app/database.
7. Navigate through production `/quiz/mock/resume/:attemptId` route and prove the same attempt, answers, flags, position, and timing resume.
8. Submit through production flow and assert production results.
9. Explicitly label this as lifecycle interruption/reconstruction, not Android process-death coverage.

**RED/GREEN**
- Run the new scenario immediately after the first journey implementation.
- Any recurrence of a mock resume product defect is a STOP/defect handoff; do not fix `lib/`.

**Verification**
- Scenario passes twice from isolated state.
- Run relevant existing mock-controller/router/persistence tests.
- `git diff --check`; commit/push.

### Task 2D: Firebase Emulator sync round trip, conflict, and isolation

**Files:**
- Create: `integration_test/release/support/firebase_emulator_harness.dart`
- Create: `test/tool/release_e2e_firebase_contract_test.dart`
- Create: `integration_test/release/firebase_sync_roundtrip_e2e_test.dart`
- Create: `integration_test/release/firebase_conflict_isolation_e2e_test.dart`

**RED — emulator contract**
1. Contract-test parsing/validation of runner-provided Auth/Firestore emulator endpoints and `demo-` project ID.
2. Contract-test that production service/project identifiers and missing emulator endpoints fail closed.
3. Contract-test that the harness never enables Functions/App Check/Google Sign-In/RevenueCat claims.
4. Run `flutter test test/tool/release_e2e_firebase_contract_test.dart` and confirm RED.

**GREEN — harness**
1. Connect Firebase Auth + Firestore instances to runner-provided emulators only.
2. Create a named emulator user and arrange a Pro custom claim using emulator-safe administration/setup; use a fresh token so production claim gateway sees the claim.
3. Seed/activate the required sync generation through emulator setup consistent with actual `firestore.rules`.
4. Build the production sync runtime using real `FirebaseFirestoreGateway`, production producers/reconciliation/runtime, isolated local `AppDatabase`s, and only the smallest existing injectable seams necessary to keep Functions out of v1.
5. If the approved production seams cannot exercise Auth/Firestore without calling Functions, stop and report the exact seam gap; do not fake a Functions success while claiming full production runtime.

**Scenario 5 — round trip**
- Named emulator user + Pro claim + active generation.
- Create meaningful local state.
- Drive production sync runtime to Firestore emulator.
- Reconstruct with an isolated local DB and pull back through production runtime.
- Assert round-trip state equality via repositories.

**Scenario 6 — conflict and isolation**
- Create stale/conflicting local/cloud row versions.
- Run current production reconciliation and assert the actual winner/merged state defined by current code.
- Authenticate a second emulator user and prove cross-user read/write is denied by the actual current `firestore.rules`.
- Do not substitute rules-unit-test-only evidence for the Android integration assertion; lower-level rule tests are supplementary.

**Verification**
- `flutter test test/tool/release_e2e_firebase_contract_test.dart`
- relevant existing sync/runtime/gateway tests
- `cd functions && npm test -- --runInBand` or repository-equivalent focused rules test including `test/firestore-sync-rules.rules.mjs`
- both Android Firebase scenarios pass twice from isolated emulator state
- `git diff --check`; commit/push.

### Task 3: Integrate and harden only from concrete failures

**Owner:** orchestrator or one narrowly assigned correction worker at a time.

1. Merge/cherry-pick Phase 2 worker commits onto `web/release-e2e-r1` only after inspecting diffs and worker fresh-verification evidence.
2. Run `git diff --name-only 0f69...HEAD`; any non-approved path is fatal.
3. Run focused tool/fixture contracts and all six scenarios once.
4. For every failure, use systematic debugging:
   - reproduce;
   - collect bounded diagnostics;
   - identify whether root cause is runner/test infrastructure, environment, or product behavior;
   - if test infrastructure, assign the smallest E2E-only correction with RED/GREEN verification;
   - if product behavior/seam, stop that path and publish a defect/authorization handoff.
5. Never weaken assertions, remove isolation, add sleeps, or fake production services to get green.

### Task 4: Complete implementation verification before independent review

Run fresh checks from the integrated Web E2E worktree:

1. Format/check touched Dart.
2. `flutter analyze`
3. `dart run tool/check_layering.dart`
4. `dart run tool/check_no_ai_attribution.dart`
5. Parse `.github/workflows/main.yml`.
6. Run all focused `test/tool/release_e2e_*_test.dart` tests.
7. Run fixture production-path tests.
8. Run relevant existing onboarding/content/quiz/mock/Settings/Auth/Firestore/rules/sync tests identified by changed surfaces.
9. Run all six Android integration scenarios against the explicitly selected device and Auth/Firestore emulators.
10. `git diff --check`
11. Verify clean source state.
12. Scan generated diagnostics/logs and source diff for secrets/credentials.
13. Verify `git diff 0f69... -- lib android pubspec.yaml pubspec.lock` is empty (or equivalent exact production-source proof).
14. Record scenario runtimes and total runtime.

Do not claim implementation complete unless every command has fresh exit-0 evidence and the diff boundary holds.

### Task 5: Independent Web review

Assign a Web reviewer with no implementation ownership. Reviewer must read the approved spec, this plan, integrated branch diff, runner tests, all six scenarios, and fresh verification evidence.

Required review verdict dimensions:
- exact six-scenario scope / no scope creep;
- no production-code divergence from `0f69...`;
- shipping DB provenance and fixture fidelity;
- no direct SQLite content seeding / no parallel content loader;
- false-positive/false-confidence risks;
- reconstruction and emulator isolation;
- bounded polling / timeout / flake risks;
- actual Auth/Firestore gateways and current rules vs mocked claims;
- no accidental Functions/App Check/Google Sign-In/RevenueCat/Play/process-death claims;
- diagnostics and secret safety;
- exact removal of only dormant CI `integration` job.

Any justified finding must be corrected through a new narrow implementation task and affected verification rerun before acceptance.

### Task 6: Final release acceptance — three isolated complete runs

After independent review findings are resolved:

1. From isolated local state, run:
   `tools/release/test_e2e.sh --candidate 0f69e79c9a13daaf7198eae62706f09dd9822ab5 --content-sha eb3a9da425b80a51331cce74694ef014c3372392194bacbd60ba145db5ea2a45 --device <explicit-adb-serial>`
   Record each scenario runtime and total runtime.
2. Clean/re-isolate state and run the exact complete command a second consecutive time. Record runtimes.
3. Restart the Android emulator/device test environment and Firebase Auth/Firestore emulator environment.
4. Run the exact complete command a third time. Record runtimes.
5. Every scenario therefore has three isolated final passes.
6. Warmed-suite target: <= 15 minutes. Hard release ceiling: 20 minutes. If the complete suite exceeds 20 minutes, do not weaken coverage; treat timing as a release E2E failure requiring investigation.
7. Repeat final static/diff/secret/clean-state checks after the third run.

### Task 7: Final handoff

Only after Task 6 and independent review are accepted, comment Pantas Issue #21 with:
- candidate `0f69e79c...`;
- exact accepted `web/release-e2e-r1` SHA;
- exact shipping content SHA;
- toolchain/environment and explicit Android target;
- six scenario results;
- all three isolated complete-run runtimes;
- lower-level/static checks;
- independent-review verdict;
- proof production source is unchanged from supplied candidate;
- explicit deferred gates;
- confirmation no replacement AAB was built;
- confirmation no Play upload occurred.

Do not call the beta accepted. Do not build an AAB. Stop after E2E acceptance and hand control back for the separately authorized final replacement signed Task 14 AAB program. Task 15 remains blocked on Google Play developer verification/live gates.
