# Pantas iOS Physical QA Enablement Design

**Status:** Approved scope, implementation not started  
**Date:** 2026-09-15  
**Decision log:** `docs/superpowers/decisions/2026-09-15-ios-physical-qa-enablement-log.md`  
**Exact baseline:** `web/e09-security-performance-verification-r1@5de8df1936be1fc6a40e100fb4624fe89a3516c0`  
**Implementation branch:** `web/ios-physical-qa-enablement-r1`

## 1. Goal

Make one physical iPhone a useful Pantas development and QA device now.

The lane must support repeatable dev/staging launches, flavor isolation, physical debugging, Firebase Core/dev-backend smoke, protected local-content/storage checks, and the existing debug Pro override.

This is **not** an iOS release-readiness project. Android E09/E10 remains the release gate.

## 2. Current source state

Exact inspection of the September 15 E09 head shows:

- the Xcode project has one shared `Runner` scheme;
- the actual Runner target has only the ordinary `Debug`, `Profile`, and `Release` configurations;
- those target configurations currently use `com.aedwon.pantas`;
- `ios/Flutter/Dev.xcconfig`, `Staging.xcconfig`, and `Prod.xcconfig` exist and name the intended Dart entrypoints/bundle IDs, but the Xcode project does not currently attach flavor-specific build configurations/schemes to them;
- the Podfile only maps `Debug`, `Profile`, and `Release`;
- `lib/firebase_options_dev.dart`, `firebase_options_staging.dart`, and `firebase_options_prod.dart` contain Android configuration only and throw for iOS;
- `lib/app/firebase_bootstrap.dart` explicitly selects `DefaultFirebaseOptions.android` for every flavor;
- `firebase.json` records Android FlutterFire registrations only;
- the Xcode project and Podfile still declare iOS 13.0;
- the resolved app already depends on Firebase Flutter plugins whose current official setup guidance requires iOS 15 or later;
- `lib/core/platform/app_check.dart` already uses the Apple debug provider for dev, while staging/prod use DeviceCheck;
- `tools/pro` is Android-oriented for automatic discovery but already accepts a generic `VM_SERVICE_URI`, so an iPhone-specific tool fork should not be needed;
- the protected-content system is already release-sensitive: the exact accepted payload, manifest, and detached signature must not be regenerated merely to run on iOS.

An August document said iPhone setup was already complete except for a cable and team selection. That statement is historical. The current branch is authoritative for what is actually wired.

## 3. External platform facts used by this design

At planning time:

- Flutter's current iOS setup requires Xcode setup/first launch, license acceptance, CocoaPods for native plugins, device trust, Developer Mode, and code signing for a physical device.
- Flutter flavors on iOS are represented by shared Xcode schemes mapped to flavor-specific Debug/Profile/Release configurations.
- Firebase's current Flutter setup requires registering/configuring each supported platform and regenerating platform-aware Firebase options.
- Firebase App Check supports an Apple debug provider for local development; debug tokens must remain private.
- Apple permits local device testing through a Personal Team without making this an App Store-distribution setup.

These are operational prerequisites, not permanent product rules.

## 4. Relationship to E09

This lane is parallel and supplementary.

### Must remain true

- Android E09 source/device security and performance evidence remains required.
- The iPhone cannot satisfy the lower-end Android performance gate.
- E10 does not start because the iPhone lane passes.
- The active E09 branch remains unchanged unless a separately accepted product repair requires a new E09 candidate.
- The iOS branch may change native iOS files and narrowly shared platform-selection code. Those changes are not merged into E09 during current acceptance work.

### Shared bug rule

If iPhone testing exposes a defect in platform-neutral Dart behavior:

1. establish the defect with a focused regression;
2. open/repair it on a dedicated branch rooted from the current E09 candidate, not by turning the iOS QA branch into a product-integration branch;
3. independently verify the repair;
4. integrate it through normal E09 ownership;
5. rerun the affected E09 physical/source evidence.

This keeps QA enablement separate from release-candidate mutation.

## 5. Flavor contract

Balanced scope requires two iOS QA flavors.

### Dev

- Xcode scheme: `dev`
- bundle ID: `com.aedwon.pantas.dev`
- display name: `Pantas Dev`
- Dart target: `lib/main_dev.dart`
- intended use: local development, Firebase dev smoke, App Check debug token, VM-service controls

### Staging

- Xcode scheme: `staging`
- bundle ID: `com.aedwon.pantas.staging`
- display name: `Pantas Staging`
- Dart target: `lib/main_staging.dart`
- intended use: product-parity/local E09 regression smoke on iPhone

The existing production/Runner configuration is not part of Balanced acceptance. Do not turn this task into production iOS signing or App Store setup.

## 6. Xcode configuration contract

The iOS project must follow Flutter's flavor model.

Required end state:

- shared `dev` and `staging` schemes;
- matching `Debug-dev`, `Profile-dev`, `Release-dev`;
- matching `Debug-staging`, `Profile-staging`, `Release-staging`;
- Run/Test/Analyze use the matching Debug configuration;
- Profile uses the matching Profile configuration;
- Archive uses the matching Release configuration;
- Podfile maps every new configuration to `:debug` or `:release` correctly;
- dev/staging use distinct bundle IDs and can coexist on one device;
- build configuration resolves the intended `FLUTTER_TARGET` and display name;
- source-controlled settings contain no personal team ID, provisioning-profile UUID, certificate identity, secret, or device UDID unless the repository already has an explicitly approved portable mechanism for it.

Automatic signing may be selected locally in Xcode. Personal signing state stays local where possible.

## 7. Minimum iOS version

The repository currently says iOS 13.0. The current Firebase Flutter setup documentation says iOS 15 or later.

Implementation must first confirm the resolved pods/toolchain requirement. If the current dependency set requires iOS 15, set the iOS QA project/Podfile deployment target consistently to 15.0.

Do not leave project, Podfile, and Pods on contradictory minimum versions.

This is a QA-branch compatibility change. A future production iOS support-floor decision remains separate.

## 8. Firebase contract

### Inspection first

Before any Firebase-console mutation:

- list the iOS apps in the dev and staging Firebase projects;
- match by exact bundle ID;
- reuse an existing exact registration when one exists;
- never create a duplicate merely because generated local options are missing.

If an exact iOS app is absent, report that external registration as the next required action. Do not silently create a project/app outside the assigned authorization.

### Generated options

Once registration exists:

- dev options must contain both Android and iOS configurations;
- staging options must contain both Android and iOS configurations;
- existing Android app IDs/options remain unchanged;
- generated options remain non-secret identifiers;
- Firebase bootstrap must choose the current platform for the selected flavor instead of hard-coding Android;
- unsupported platforms must still fail honestly.

### Required Balanced proof

Dev must prove:

- Firebase Core initializes on the physical iPhone;
- the existing runtime reaches a narrow Firebase-backed path without platform-configuration failure;
- App Check debug mode can produce/use a private registered debug token when enforcement requires it.

Staging must prove Firebase Core configuration if the registration exists. DeviceCheck/App Attest backend enforcement is **not** required for Balanced acceptance.

## 9. App Check boundary

Current behavior is retained unless a concrete defect requires a change:

- dev: Apple debug provider;
- staging: current non-dev provider behavior remains unless a separately reviewed QA-only configuration is necessary.

A debug token:

- is never committed;
- is never placed in a checked-in scheme/environment file;
- is never pasted into an issue or result log;
- may be registered only in the corresponding Firebase app's debug-token allowlist.

Do not weaken production attestation to make this QA lane easier.

## 10. Protected-content and Keychain contract

iPhone testing must exercise the existing protected-content design, not invent a second iOS storage architecture.

### Package identity

Use the exact protected package already accepted for the current E09 candidate:

- same `content.db` bytes;
- same manifest bytes;
- same detached signature bytes.

Do not rebuild or re-sign it.

Only the bootstrap key is needed for an authorized app test. The signing seed is not needed and must not be loaded.

### Required physical observations

On a physical iPhone:

1. first protected-content install/open succeeds;
2. study/quiz content is readable by the app while offline;
3. process death and relaunch reopen the protected content;
4. user progress remains intact across relaunch;
5. secure-storage-backed keys are available through the app after relaunch;
6. when a development app container can be copied/downloaded, an ordinary unkeyed SQLite open of the installed protected content fails;
7. temporary/journal files are inventoried if visible;
8. uninstall/reinstall behavior is observed without assuming that Keychain items are deleted with the app.

Any platform-specific Keychain persistence finding is evidence to record, not something to "fix" without a separate contract decision.

## 11. VM-service Pro switching

No new debug entitlement UI is authorized.

Use the existing service extension and `tools/pro`:

1. run/attach the dev app on iPhone;
2. capture the host-reachable Dart VM Service URI from Flutter;
3. invoke `tools/pro` with `VM_SERVICE_URI=<uri>`;
4. verify report -> Pro -> Free -> clear;
5. verify the visible app state changes without reinstall/rebuild.

Only modify `tools/pro` if the explicit URI path is proven broken on iOS. Android auto-discovery must not regress.

## 12. Balanced physical acceptance matrix

Target: approximately 8-12 checks. The exact count is less important than covering these boundaries.

### Tooling/device

- Xcode first-run/license/platform setup complete.
- Physical iPhone trusted, Developer Mode enabled, development signing works.

### Flavor isolation

- dev installs and launches.
- staging installs and launches.
- both can coexist on the device and show the correct display name/environment.

### Runtime/platform

- cold dev launch.
- cold staging launch.
- background/resume and process-death relaunch.
- representative offline lesson/quiz flow.

### Firebase dev smoke

- Firebase Core initializes.
- narrow existing Auth/Firestore-backed runtime path does not fail due to missing iOS config.
- App Check debug path is accepted when required.

### Protected storage

- protected content opens offline and after process death.
- extracted development container, when available, does not expose content through an ordinary unkeyed SQLite open.
- Keychain persistence behavior is recorded.

### Debug entitlement

- `tools/pro` works through explicit VM Service URI for on/off/clear.

### Product regression smoke

Use reachable non-destructive state to smoke current E09 defects/repairs where meaningful, especially:

- zero-content exam behavior (#25);
- exam-switch transition/carry-over behavior (#26);
- Resume positional count (#27);
- stale Resume card after completion (#28).

Do not clear or destroy preserved state merely to force a scenario.

## 13. Visual verification

Repository workers do not claim visual acceptance from screenshots.

Workers report text/runtime signals. Aedwon performs the physical visual check and records any UI finding through the normal audit/issue process.

## 14. Out of scope

Balanced does not include:

- App Store Connect;
- TestFlight;
- distribution signing;
- production iOS archive acceptance;
- App Store version identity;
- APNs;
- FCM push validation;
- production DeviceCheck/App Attest rollout;
- Google Sign-In iOS production configuration;
- Sign in with Apple launch;
- RevenueCat iOS products/purchases/restores;
- App Store privacy labels;
- Store review;
- broad iOS performance certification;
- replacing Android E09 evidence.

## 15. Exit

Balanced iOS QA enablement is complete when:

1. the isolated branch has reviewable dev/staging flavor wiring;
2. Xcode/Flutter can run both flavors on the physical iPhone under local development signing;
3. the exact accepted protected package can be used without regeneration;
4. dev Firebase configuration initializes on iOS and the bounded backend smoke is evidenced;
5. protected content/Keychain/relaunch checks are recorded;
6. `tools/pro` works through the explicit VM Service URI;
7. the bounded physical smoke matrix is completed or each untestable item has a concrete external blocker;
8. required repository source gates are green for the branch;
9. no claim is made that this work satisfies Android E09, E10, or App Store readiness.

The branch then remains a QA-enablement line until a separate integration decision says when its platform configuration should enter a release candidate.
