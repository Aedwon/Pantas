# Release E2E and integration-test suite design

Date: 5 September 2026

Status: approved on 5 September 2026

Current release candidate:
`0f69e79c9a13daaf7198eae62706f09dd9822ab5`

Current approved shipping content SHA-256:
`eb3a9da425b80a51331cce74694ef014c3372392194bacbd60ba145db5ea2a45`

## 1. Purpose

This program adds a compact local Android release suite for the current Pantas
beta candidate. It tests the highest-risk journeys that do not require Google
Play developer verification. The suite provides pre-Play release evidence. It
does not accept the beta and does not complete Task 15.

The suite must prove real boundaries that the current unit and widget tests do
not cross:

- approved bundled content to an installed database;
- production Flutter presentation through domain logic to an on-device database;
- persisted learning state after the app tree and database connections are
  reconstructed;
- repaired mock progress through the production resume route;
- production Auth and Firestore gateways against local emulators;
- current Firestore rules, including cross-user denial;
- row-level cloud and local conflict handling.

The suite stays small enough to run before every release-candidate artifact build.

## 2. Authority and frozen inputs

GitHub Issue #21 is the current release-status authority. It records that:

- `origin/main` remains frozen at
  `b642e2d169e0a03120d4f71cc6e10a6148cc5ef0`;
- the accepted RevenueCat repair is
  `e9f9ad6537d1573642e5d0e763cf858d01862aae`;
- the accepted mock-resume repair is
  `7a5257ec76d15bcc6158b450b667bb100625383b`;
- the exact combined local beta candidate is
  `0f69e79c9a13daaf7198eae62706f09dd9822ab5`;
- the remote beta ref remains on the RevenueCat parent because no push was
  authorized;
- all earlier signed AABs are historical after the combined source changed.

The combined candidate is a merge whose two parents are the RevenueCat repair
and the mock-resume repair. Both repair commits descend directly from the old
candidate. The Release E2E branch was fast-forwarded to the combined candidate.
`main` did not move.

The runner does not embed these release values permanently. A release owner must
supply the expected candidate SHA, shipping content SHA, and ADB device serial on
every run. The spec records today's values for this candidate's acceptance only.

## 3. Current test architecture

The repository has extensive tests under `test/`. These tests cover domain logic,
repositories, widgets, routing, bootstrap seams, the sync engine with test
gateways, Firebase gateway mapping with test clients, and the repaired mock route
with an in-memory database. They do not run a complete production journey on an
Android device.

The Flutter SDK `integration_test` dependency already exists. The repository has
no top-level `integration_test/` suite today.

The main-push workflow contains a macOS integration job. It checks for test files
directly under `integration_test/` and reports a skipped `integration` check when
none exist. No downstream job needs that job. No active branch-protection or
ruleset contract requires its name. Historical design documents expected device
integration tests, but the current release decision replaces hosted execution
with this explicit local suite.

The Functions test command runs the existing static JavaScript tests. The
separate RevenueCat behavior tests also run locally. The current Functions folder
does not have a deployable local-emulator package contract. This program does not
repair or imitate that missing contract.

## 4. Scope

### 4.1 Included

The v1 suite contains six scenarios:

1. shipping-content cold start, onboarding, offline learning, and persisted lesson
   completion;
2. deterministic quiz completion and persisted learning state;
3. deterministic mock interruption, reconstruction, resume, and submission;
4. anonymous local-data deletion through Settings;
5. emulator-backed Auth and Firestore sync round trip;
6. emulator-backed row reconciliation and hard cross-user denial.

The program also adds:

- one local release runner;
- deterministic fixture source and builders;
- small shared integration-test helpers;
- safe text diagnostics;
- release-suite documentation;
- focused static tests for the runner and CI contract;
- removal of the dormant macOS integration job.

### 4.2 Excluded

The suite does not automate:

- Google Play upload or installation;
- a signed AAB or Play-distributed build;
- Play Billing purchases, restores, renewals, cancellations, expirations, or
  refunds;
- RevenueCat production entitlement changes;
- Play Integrity;
- production App Check enforcement;
- production Firebase latency, indexes, limits, or transaction behavior;
- native Google Sign-In;
- named-account deletion or data export;
- callable Functions or Functions emulator behavior;
- true Android process death;
- visual, TalkBack, large-text, or physical-device acceptance;
- notification permission, exact-alarm, reboot, time-zone, or daylight-saving
  behavior.

Assessment, bookmarks, notification routing, and force-update routing remain at
their existing lower-level test seams. Their incremental device-test value does
not justify more v1 scenarios.

## 5. Architecture

### 5.1 Layer A: local Android application E2E

Layer A runs through Flutter `integration_test` on one explicitly selected
Android emulator or device. It uses the production `App`, routes, controllers,
repositories, Drift databases, secure storage, content installer, and content
database opener.

The test target composes the app through existing dependency-injection seams. It
does not run production Firebase, Remote Config, App Check, RevenueCat,
notifications, reviews, or telemetry. Those services use their existing disabled
or deterministic test implementations. The harness does not add a broad
`isTest` branch to production code.

No `lib/`, `android/`, or product dependency change is planned. The tests use
existing semantics, text, routes, and providers. If a stable test identifier or
new production seam becomes necessary, implementation stops for approval.

### 5.2 Layer B: Firebase Emulator integration

Layer B starts only the Auth and Firestore emulators. It uses a project ID with a
`demo-` prefix. The Android test initializes Firebase with that same demo project
and points Auth and Firestore to `10.0.2.2` before either SDK is first used.

Test setup may create named emulator users, Pro claims, active generations, and
starting Firestore documents through a test-only Firebase Admin helper connected
to the local emulators. The helper sets `FIREBASE_AUTH_EMULATOR_HOST` and
`FIRESTORE_EMULATOR_HOST` before Firebase Admin initializes. It supplies the
same `demo-` project ID directly and rejects credentials or nonlocal hosts. The
helper may create email/password users and set their Pro custom claims. The
Android client then signs in through the Auth emulator so its ID token carries
those claims into the real Firestore rules. This setup establishes preconditions.
It does not count as behavior under test and adds no product dependency.

The behavior under test uses:

- the Firebase Android SDK;
- the production Firebase Auth gateway;
- the production Firebase Firestore gateway;
- the production sync runtime engine and mapping code;
- the repository's current `firestore.rules`.

The tests do not install a fake Auth gateway, Firestore gateway, or rules layer.
They do not fake a Functions response. An active generation is provisioned before
the engine starts, so the suite tests row sync after activation. Generation
activation and account-level reconciliation choices remain Functions coverage
and are deferred.

Layer B may claim local emulator Auth behavior, Firestore client behavior,
row-level reconciliation, and rules enforcement. It may not claim production
Firebase acceptance.

### 5.3 Layer C: manual and Play-dependent acceptance

Layer C is documentation only. Issue #21 and the release-suite guide retain the
full Task 15 list. Passing Layers A and B does not change Task 15 status.

## 6. Release provenance contract

The public runner interface is:

```text
tools/release/test_e2e.sh \
  --candidate <40-character Git SHA> \
  --content-sha <64-character SHA-256> \
  --device <ADB serial>
```

All three values are mandatory and immutable for one invocation. The runner
prints them before preflight and repeats them in the final summary.

The runner performs these checks before it clears any state or launches an app:

1. The current directory belongs to the Pantas repository.
2. The worktree has no tracked or untracked changes except ignored build output.
3. The candidate argument is a full commit object.
4. The candidate is an ancestor of the checked-out E2E branch.
5. Every file changed from the candidate belongs to the approved E2E surface.
6. `assets/seed/content.db` exists.
7. Its full SHA-256 equals `--content-sha`.
8. The full digest starts with `contentSeedVersion` read from
   `lib/core/content/content_seed_version.dart` at both the candidate commit and
   the checked-out branch. Those two tracked prefixes must also match each other.
9. The selected device is connected, online, and the only target used by every
   Flutter and ADB command.
10. The pinned release toolchain is available.

The approved E2E surface is:

- `integration_test/release/`;
- `tools/release/test_e2e.sh` and its release-E2E helper directory;
- focused tests under `test/tool/` for this runner and workflow contract;
- Release E2E documentation, spec, plan, research, and decision records;
- deletion of only the dormant `integration` job from
  `.github/workflows/main.yml`.

Any other diff from the supplied candidate is fatal. This check prevents a suite
pass from hiding a product-code change that never received separate acceptance.

For the current combined candidate, the release owner supplies:

```text
--candidate 0f69e79c9a13daaf7198eae62706f09dd9822ab5
--content-sha eb3a9da425b80a51331cce74694ef014c3372392194bacbd60ba145db5ea2a45
```

The tracked prefix for this candidate is `eb3a9da425b80a51`.

These values appear in release evidence. They do not become reusable script
defaults.

## 7. Content strategy

### 7.1 Shipping database

Scenario 1 uses the existing `assets/seed/content.db`. The runner verifies its
full digest and its tracked version prefix before launch. It never runs a content
export or seed build for this scenario. A missing file, unknown candidate,
missing candidate prefix, or digest mismatch ends the suite before app launch.

The scenario calls the production content installer with its default bundled
asset loader and default destination. It opens the installed database through the
production content database opener. It does not copy a database from another
worktree or replace the approved corpus.

### 7.2 Deterministic fixture

Scenarios 2 through 4 use one tiny tracked fixture definition. It contains only
the records needed for one exam, one subject, one topic, one lesson, deterministic
quiz questions, and one small mock blueprint. All IDs, content, ordering, and
timestamps are fixed.

The fixture source is a Dart data definition compiled into the integration test.
The test writes that definition as the production export JSON shape. It then
calls the production `writeContentSeed` function. The production content schema,
Sanity parsers, and seed writer create the SQLite file.

The test reads those generated bytes through the existing installer loader seam.
The production installer writes the standard destination. The production opener
then opens it. Tests never insert content rows directly and never maintain a
second database builder.

The fixture database is generated for each isolated scenario. It remains under
device or ignored build storage. Git tracks only the minimal fixture source.

The fixture removes random dependence by supplying exactly the eligible records
for each selection. Assertions use fixed IDs and stored domain state. Tests avoid
locale-dependent date text and wall-clock-sensitive values.

## 8. Scenario contracts

### 8.1 Scenario 1: shipping cold start and offline learning

Preconditions:

- candidate and content provenance passed the runner preflight;
- the app package has no local data;
- external Firebase and RevenueCat bootstraps are disabled through existing
  injection seams;
- the approved shipping asset remains unchanged.

Journey:

1. Install the approved content asset through the production installer.
2. Open the content and encrypted application databases through their production
   openers.
3. Launch the production app tree.
4. Complete the age gate and onboarding.
5. Select a real exam from the approved corpus.
6. Reach Home, open Study, expand a topic, and open a real lesson.
7. Complete the lesson's supported read action.
8. Verify the lesson-progress row in the encrypted application database.
9. Dispose the app tree and provider container.
10. Close and reopen both databases.
11. Rebuild the app tree and verify that onboarding stays complete and the lesson
    remains read.

This scenario proves approved bundled-content installation, local-first startup,
the first learning journey, encrypted local persistence, and restoration after
app-tree reconstruction. It does not prove production Firebase unavailability or
Android process death.

### 8.2 Scenario 2: quiz to persisted learning state

Preconditions:

- clean app data;
- the deterministic fixture installed and opened through the production path;
- a fixed UTC clock where existing provider seams permit one;
- exactly the eligible fixture questions needed by the chosen quiz mode.

Journey:

1. Complete the minimal first-run state.
2. Start the selected production quiz mode through the UI.
3. Answer each fixture question with known choices.
4. Submit and reach the production result or debrief surface.
5. Verify the persisted attempt, review state, review log, and relevant progress
   change in the encrypted database.
6. Dispose and reconstruct the app and database connections.
7. Verify the attempt and learning state again through both repository reads and
   the relevant user-facing surface.

This scenario proves the main learning loop across presentation, domain, and
native persistence. Existing scheduler unit tests remain the authority for
mathematical correctness at many dates and ratings.

### 8.3 Scenario 3: mock interruption and resume

Preconditions:

- clean app data;
- the deterministic fixture includes one valid mock blueprint and only its
  required questions;
- normal non-strict mock mode is active.

Journey:

1. Start the mock through its production setup and start routes.
2. Read the created attempt identity from the database.
3. Answer one question, flag another, advance position, and allow timing to move
   forward.
4. Send a real Flutter application lifecycle pause event.
5. Poll the database until the production persistence path records the changed
   snapshot.
6. Record the persisted answers, flags, current position, elapsed time, and
   attempt identity.
7. Dispose the app tree and close the database connections.
8. Reopen the databases and rebuild the app tree.
9. Navigate to the Quiz panel and use its production Resume action.
10. Verify that the route opens the same attempt and restores its answers, flags,
    position, and nondecreasing elapsed time.
11. Complete and submit the mock.
12. Verify the same attempt becomes completed and its production results are
    available.

This scenario proves the repaired interruption and reconstruction contract. It
does not claim that the Android process was killed.

### 8.4 Scenario 4: anonymous local-data deletion

Preconditions:

- clean app data;
- deterministic fixture content;
- a deterministic anonymous auth state installed through the existing provider
  seam;
- meaningful lesson, quiz, and mock progress in the local database.

Journey:

1. Open Settings and the anonymous Delete data page.
2. Verify the page promises deletion of progress on this device.
3. Confirm deletion through the production control.
4. Wait for the completion state.
5. Verify that all local progress tables covered by the production wiper are
   empty.
6. Verify that the content database still opens.
7. Verify that device-scoped settings which the production contract retains are
   still present.
8. Reconstruct the app tree and confirm a usable local app remains.

This scenario proves only anonymous data deletion on one device. It does not
prove named-account deletion, backend deletion, subscription cancellation, or
data export.

### 8.5 Scenario 5: emulator sync round trip

Preconditions:

- clean app data and clean Auth and Firestore emulator state;
- one demo project ID shared by app initialization and both emulators;
- a named emulator user with a Pro claim;
- one active generation provisioned by emulator setup;
- Firestore client persistence cleared by app-data isolation.

Journey:

1. Sign the Android Firebase SDK into the named emulator account.
2. Verify that the production Auth gateway exposes the expected named identity.
3. Create meaningful local progress in database A through a production
   repository.
4. Start the production sync runtime engine with database A, the real Firestore
   gateway, and the pre-provisioned generation.
5. Force a sync and poll the emulator until the expected document exists under
   the user's active generation.
6. Stop the first engine and open a clean database B with a different device ID.
7. Start the production engine for database B against the same generation.
8. Poll until database B contains the expected domain row.
9. Verify the stored payload, authoritative server timestamp, origin device, and
   mutation identity.

This scenario proves a real local-to-Firestore-to-local round trip after
generation activation. It does not prove the callable that activates a
generation.

### 8.6 Scenario 6: reconciliation and cross-user denial

Preconditions:

- fresh app and emulator state;
- named Pro user A and named Pro user B;
- an active generation for user A;
- one accepted row version for user A in both Firestore and local row metadata.

Journey:

1. Create a pending local update for user A based on the accepted version.
2. Write a newer conflicting server version through emulator setup as another
   device.
3. Start the production runtime engine for user A.
4. Verify that the current row-level policy accepts the newer server version,
   removes the obsolete local lineage, and preserves a valid authoritative base.
5. Sign out of the emulator account and sign in as user B.
6. Attempt to read user A's synchronized collection through the production
   Firestore gateway.
7. Require a Firestore permission-denied error.
8. Verify that no user A payload reached user B's local database.

This scenario proves row-level conflict handling and hard cross-user denial under
the current rules. It does not prove the user-facing choice between local and
cloud generations because that choice requires the deferred Functions path.

## 9. App reconstruction and process death

App reconstruction means:

- dispose the Flutter app tree;
- dispose its provider container;
- close both database connections;
- reopen the same files through production openers;
- build a new provider container and app tree.

The suite always calls this app reconstruction. It never labels it process death.

Flutter widget rebuilding and `restartAndRestore` do not kill the Android
process. The v1 runner therefore keeps true process death as a separate ADB
preflight:

```text
adb shell am force-stop <package>
adb shell am start -W -n <package>/.MainActivity
```

That preflight belongs to manual device acceptance until a reliable two-process
test protocol receives separate approval. It uses force-stop for persistence and
`pm clear` only for a fresh-install state.

## 10. Runner behavior

### 10.1 Toolchain and target checks

The runner verifies:

- Flutter 3.41.9 at framework revision
  `00b0c91f06209d9e4a41f71b7a512d6eb3b9c694`;
- Dart 3.11.5 through that Flutter installation;
- JDK 17;
- Gradle 8.14;
- AGP 8.11.1;
- ADB availability;
- Firebase CLI availability;
- the selected Android device state;
- the dev package identity used by the integration-test target.

It exports the repository-required Swift Package Manager setting for Flutter
commands. It passes the selected device to every Flutter and ADB command.

### 10.2 Scenario isolation

The runner invokes every scenario file separately and in a fixed list. Before
each scenario, it clears the dev app package. This resets the encrypted database,
secure-storage key, shared preferences, Firebase Auth state, and Firestore cache.

Before each emulator scenario, it also clears Auth accounts and Firestore
documents through the documented local REST endpoints. It verifies those clear
operations. Cleanup failure stops the run.

The two emulator scenarios run inside one `firebase emulators:exec` process with
only `auth,firestore` enabled. Each receives its own full reset. The project ID
must start with `demo-`. The runner rejects production project IDs, production
credentials, Google application credentials, RevenueCat keys, and production
Firebase configuration inputs.

Each test owns its setup and assertions. No scenario depends on an earlier
scenario's output.

### 10.3 Waiting and timeouts

Tests poll explicit state predicates with bounded timeouts. They do not use fixed
sleeps to wait for asynchronous persistence, routing, or emulator changes.
Timeout messages name the state that failed to appear.

### 10.4 Diagnostics

The runner creates one ignored directory under `build/release-e2e/` for each
invocation. It records:

- candidate SHA;
- content SHA;
- device serial and Android API level;
- Flutter, Dart, Java, Gradle, AGP, Firebase CLI, and emulator versions;
- scenario name;
- start and end timestamps;
- command exit status;
- bounded Flutter and emulator log excerpts;
- final pass or failure summary.

Diagnostics redact or reject values that resemble credentials, authorization
headers, tokens, cookies, private keys, Firebase configuration secrets, or learner
payloads. The suite never captures screenshots or video.

The runner prints the immutable provenance at the start and end. Any preflight,
scenario, reset, cleanup, or summary-write failure returns nonzero.

### 10.5 Runtime target

The warmed local suite targets 15 minutes or less after the Android and Firebase
emulators are available. Twenty minutes is the release ceiling. This excludes
one-time SDK, Gradle, and package downloads. Implementation records measured
scenario and total runtimes. If the suite exceeds the ceiling, acceptance stops
until the plan removes redundant setup or narrows a scenario without weakening
its approved claim.

## 11. CI policy

Implementation removes only the `integration` job from
`.github/workflows/main.yml`. The existing `ci` job remains byte-for-byte
unchanged. No replacement hosted emulator, simulator, or device job is added.

The removal is safe under the current repository state:

- no workflow job depends on `integration`;
- the `integration` check is currently skipped;
- no active branch protection or ruleset requires it;
- Issue #21 does not name it as a beta gate;
- historical documents describe an intended integration layer, not a required
  current hosted check.

The Release E2E guide states that device execution is intentionally local and
release-candidate driven through `tools/release/test_e2e.sh`. This is a cost and
reliability decision. It is not a file-discovery trick.

After the edit, verification parses the YAML, confirms that only the dormant job
was deleted, runs focused workflow and release-contract tests, and runs the
repository's standard static checks.

## 12. Failure policy

Flakiness is a test defect. The suite is incomplete if any scenario depends on
order, external network state, a production credential, a fixed sleep, or an
uncleared cache.

If an E2E scenario exposes a product defect, work stops. The E2E branch records:

- exact reproduction;
- severity;
- affected candidate behavior;
- exact failing scenario;
- release impact;
- whether beta is blocked.

The test program does not repair the product defect. A separately authorized
narrow repair must return through candidate integration and full verification.

If the Firebase Emulator cannot represent the contract a test would claim, that
test is removed or narrowed. The suite never substitutes a fake and keeps the
broader claim.

## 13. Verification and flake budget

Implementation follows test-first development. Each scenario begins with a
failing proof that the current lower-level tests do not provide. Helpers are added
only when a scenario needs them.

Final verification uses the exact final E2E branch commit and supplied candidate.
It includes:

- Dart formatting for touched Dart files;
- Flutter analyzer;
- layering check;
- no-AI-attribution check;
- workflow YAML parse and focused workflow/static tests;
- runner unit or shell-contract tests;
- fixture seed-writer and loading-path tests;
- every new Android integration test;
- relevant existing onboarding, content, quiz, mock, Settings, Auth, Firestore,
  rules, and sync tests;
- Firebase Emulator scenarios;
- `git diff --check`;
- clean source status;
- a scan for production secrets and forbidden diagnostics.

The complete runner must pass twice consecutively from isolated state. The
Android emulator and Firebase emulators are then restarted, and the complete
runner passes once more. Every scenario therefore receives three final isolated
passes. Any intermittent failure blocks acceptance.

Final evidence records:

- supplied candidate SHA;
- final E2E branch SHA;
- shipping content SHA;
- toolchain versions;
- device model, serial, and API level;
- Firebase CLI and emulator versions;
- six scenario results;
- three full-suite run results and runtimes;
- relevant lower-level test results;
- independent review verdict;
- all deferred Play, Functions, production Firebase, and manual checks;
- confirmation that no replacement AAB was built;
- confirmation that no Google Play upload occurred.

## 14. Independent review

After implementation and local verification, an independent reviewer checks:

- scope compliance;
- production-code divergence;
- fixture fidelity;
- false-positive and false-confidence risks;
- scenario isolation;
- timeout and flake risks;
- emulator claims against actual rules and gateways;
- accidental Functions, App Check, Google Sign-In, RevenueCat, Play, or
  process-death claims;
- safe diagnostics and secret handling;
- CI removal scope.

The primary agent inspects the review and reruns affected checks before accepting
the suite.

## 15. Deliverables

The approved implementation produces:

1. this design spec;
2. a detailed implementation plan;
3. six scenario-oriented Android integration tests;
4. deterministic fixture source and shared helpers;
5. Auth and Firestore Emulator setup and tests;
6. `tools/release/test_e2e.sh`;
7. a concise Release E2E guide;
8. the dormant hosted integration-job removal;
9. focused runner and workflow contract tests;
10. fresh verification evidence and an Issue #21 handoff.

Generated databases, emulator exports, logs, screenshots, videos, tokens, and
credentials never enter Git.

## 16. Handoff after acceptance

The E2E program does not mark the beta accepted. Its Issue #21 handoff states:

- exact combined candidate SHA;
- exact accepted E2E branch SHA;
- automated scenarios;
- environment and toolchain;
- repeat and flake evidence;
- production source remained unchanged from the supplied candidate;
- Functions and Task 15 gaps remain;
- no replacement AAB was built;
- no Google Play upload occurred.

After the E2E suite is accepted, control returns to the release coordinator. The
next authorized program builds the final replacement signed Task 14 AAB from the
accepted combined candidate and reruns the full artifact verification. Task 15
still waits for Google Play developer verification and the remaining live and
human acceptance gates.

## 17. Design answers

1. **Existing E2E layers:** no Android application E2E suite exists. Current
   integration-named tests run lower-level code with in-memory storage or test
   gateways.
2. **Why CI skipped:** the hosted job looked only for top-level integration test
   files, and none existed.
3. **Lower-level coverage kept:** assessment, bookmarks, notifications,
   force-update routing, scheduler mathematics, Functions behavior, and many
   repository rules remain in their current tests.
4. **Highest-value journeys:** the six scenarios in Section 8.
5. **Real Android requirement:** all Layer A scenarios and the production
   FlutterFire gateway portions of Layer B.
6. **Firebase Emulator use:** Auth identity, Firestore row sync, reconciliation,
   and security rules only.
7. **Unavailable before Play:** billing, RevenueCat lifecycle, Play Integrity,
   Play distribution, production App Check, and final physical-device acceptance.
8. **Deterministic data:** exact shipping content for Scenario 1 and a minimal
   production-seed-writer fixture for Scenarios 2 through 4.
9. **Clean state:** `pm clear`, Auth clear, Firestore clear, verified cleanup, and
   independent scenario setup.
10. **Production isolation:** disabled local providers for Layer A and a demo-only
    Auth and Firestore project for Layer B.
11. **Runtime target:** 15 minutes or less on a warmed local environment, with a
    20-minute release ceiling and measured scenario runtimes.
12. **Process death:** manual ADB preflight only. App reconstruction has a narrower
    label.
13. **CI effect:** remove only the dormant macOS job and document local execution.
14. **Single command:** the argument-driven runner in Section 6.
15. **Completion evidence:** three isolated full-suite passes, relevant static and
    lower-level checks, independent review, exact SHAs, and explicit deferred
    gates.
