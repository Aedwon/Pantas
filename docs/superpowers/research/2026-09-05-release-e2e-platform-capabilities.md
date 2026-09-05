# Release E2E platform capabilities

Date: 2026-09-05

Candidate: `0f69e79c9a13daaf7198eae62706f09dd9822ab5`

Scope: local Android Flutter E2E with optional Firebase Local Emulator Suite.

This note records platform facts that the balanced release E2E design can claim. It does not claim that the candidate already has the harness. The candidate has the `integration_test` dependency, but no `integration_test/` directory and no SDK calls that route Auth, Firestore, or Functions to local emulators.

## Flutter integration tests

Flutter's official integration-test guide supports Android devices and emulators. The local command is `flutter test integration_test/app_test.dart`. The test uses `IntegrationTestWidgetsFlutterBinding`, then drives Flutter widgets through `WidgetTester`. The Android example installs an APK and runs the test on the selected device.

Sources:

- [Flutter integration tests](https://docs.flutter.dev/testing/integration-tests)
- [`IntegrationTestWidgetsFlutterBinding` example](https://docs.flutter.dev/testing/integration-tests#write-the-integration-test)

`tester.pumpWidget(...)` calls `runApp`, attaches a new root widget to the Flutter test binding, schedules a frame, and pumps it. A later call forces a full widget-tree rebuild. This is a Dart/Flutter tree operation. It is not an Android process restart.

`tester.restartAndRestore()` also stays inside the Flutter test binding. Its implementation temporarily calls `runApp`, pumps, restores Flutter restoration data, and pumps again. It does not call Android's activity manager and does not kill the app process.

Sources:

- [`WidgetTester.pumpWidget`](https://api.flutter.dev/flutter/flutter_test/WidgetTester/pumpWidget.html)
- [`WidgetTester.restartAndRestore`](https://api.flutter.dev/flutter/flutter_test/WidgetTester/restartAndRestore.html)

The official Firebase Test Lab instructions build a debug APK because a standard release build does not include `package:integration_test`. This means an `integration_test` run alone cannot honestly be called validation of the signed release AAB or of a Play-installed artifact. A release-like lifecycle check needs an externally launched installed artifact, such as an APK plus `adb`, or a separate device-test setup.

Source: [Flutter integration tests, Test Lab Android setup](https://docs.flutter.dev/testing/integration-tests#test-in-firebase-test-lab-android)

## Android process interruption and relaunch

The Android Debug Bridge exposes the Activity Manager through `adb shell am`.

- `am force-stop package-id` force-stops everything associated with the package.
- `am start -W -n package-id/activity-component` explicitly starts the activity and waits for launch completion.
- `am start -S -W -n package-id/activity-component` force-stops the target app before starting it.
- `am kill package-id` is not equivalent. Android documents it as killing only processes that are safe to kill and that will not affect the user experience.

Sources:

- [Android Debug Bridge, Activity Manager commands](https://developer.android.com/tools/adb#am)
- [Android Debug Bridge, package manager data commands](https://developer.android.com/tools/adb#pm)

After a force-stop, Android puts the package in the stopped state. The package cannot self-start until an explicit request starts one of its components. An explicit `am start` is therefore the deterministic relaunch operation for this suite.

Source: [Android `ACTION_PACKAGE_RESTARTED` and stopped-package behavior](https://developer.android.com/reference/android/content/Intent#ACTION_PACKAGE_RESTARTED)

The candidate's Android launch component is `.MainActivity`. Its flavor package IDs are:

- Dev: `com.aedwon.pantas.dev`
- Staging: `com.aedwon.pantas.dev.staging`
- Prod: `com.aedwon.pantas`

Examples for the candidate are therefore:

```sh
adb shell am force-stop com.aedwon.pantas.dev
adb shell am start -W -n com.aedwon.pantas.dev/.MainActivity
```

or, as one operation:

```sh
adb shell am start -S -W -n com.aedwon.pantas.dev/.MainActivity
```

Force-stop is not a data reset. Android documents `pm clear package-id` separately as deleting all data associated with a package. Use `force-stop` plus relaunch to test persisted state across a new process. Use `pm clear` only when the scenario needs a fresh app installation state. The official docs do not promise that force-stop clears Flutter, Drift, Firebase Auth, or Firestore state.

Android's Monkey tool can launch a package with `adb shell monkey -p package-id --dbg-no-events 1`, but it is an event exerciser. Component-based `am start -W -n` is the better release runner primitive because it names the activity and does not add random input.

Source: [Android Monkey tool](https://developer.android.com/studio/test/other-testing-tools/monkey)

## Firebase Local Emulator Suite

The suite supports Authentication, Cloud Firestore, Cloud Functions, and other Firebase products. The Functions emulator supports HTTP, callable, and background-triggered functions. The emulators are intended for integration testing and QA, not as production services. The Functions emulator is currently documented as beta.

Sources:

- [Local Emulator Suite introduction](https://firebase.google.com/docs/emulator-suite)
- [Connect to the Cloud Functions emulator](https://firebase.google.com/docs/emulator-suite/connect_functions)

The candidate's `firebase.json` declares these default ports:

- Auth: `9099`
- Firestore: `8080`
- Functions: `5001`
- Storage: `9199`
- Emulator UI: `4000`

The Android emulator reaches services bound to the host computer through `10.0.2.2`, not the app's own `localhost`. Firebase's Android examples use `10.0.2.2` for Auth, Firestore, and callable Functions.

Sources:

- [Auth emulator Android connection](https://firebase.google.com/docs/emulator-suite/connect_auth#instrument_your_app_to_talk_to_the_emulator)
- [Firestore emulator Android connection](https://firebase.google.com/docs/emulator-suite/connect_firestore#instrument_your_app_to_talk_to_the_emulator)
- [Functions emulator Android connection](https://firebase.google.com/docs/emulator-suite/connect_functions#instrument_your_app_for_callable_functions)

The FlutterFire client APIs map to those endpoints as follows:

```dart
await FirebaseAuth.instance.useAuthEmulator('10.0.2.2', 9099);
FirebaseFirestore.instance.useFirestoreEmulator('10.0.2.2', 8080);
FirebaseFunctions.instanceFor(region: 'asia-southeast1')
    .useFunctionsEmulator('10.0.2.2', 5001);
```

These calls must run after Firebase initialization and before the first use of each SDK service. The current candidate has no such calls, so it cannot yet make an emulator-backed Android E2E claim.

Use one project ID for all emulators and app initialization. Firebase documents matching project IDs as required for cross-service interactions, including Auth-backed rules and database-triggered Functions. A demo project ID is safer because an un-emulated product cannot fall through to a live resource.

Source: [Emulator project selection and cross-service behavior](https://firebase.google.com/docs/emulator-suite/connect_firestore#choose_a_firebase_project)

## Auth emulator

FlutterFire documents `useAuthEmulator(host, port)`. Native Android emulator traffic should use `10.0.2.2:9099`. The Auth emulator supports account creation and management for common flows, including email/password, phone, anonymous, and third-party provider testing. It exposes a REST endpoint that deletes all accounts in a project:

```sh
curl -X DELETE \
  http://localhost:9099/emulator/v1/projects/pantas-dev-090126/accounts
```

Source: [Firebase Auth emulator REST API](https://firebase.google.com/docs/reference/rest/auth#clear_user_accounts)

Native Firebase Auth persists the signed-in user on Android across app restarts. A force-stop and relaunch therefore tests a new process with the Auth session still present. It does not create a signed-out baseline. Use the Auth REST clear endpoint and `adb shell pm clear` when a scenario needs both server and device Auth state reset.

Source: [Firebase Auth for Flutter, persisted native state](https://firebase.google.com/docs/auth/flutter/start#persisting_authentication_state)

Auth emulator ID tokens are unsigned. Firebase documents that they are accepted by other emulators and by an Admin SDK configured for the Auth emulator. Production Firebase services reject them. An Auth-emulator sign-in cannot be used as evidence that production Auth accepts the same identity.

Source: [Auth emulator ID tokens](https://firebase.google.com/docs/emulator-suite/connect_auth#id_tokens)

The Firebase Admin SDK automatically connects to the Auth emulator when
`FIREBASE_AUTH_EMULATOR_HOST` is set without a protocol. It also accepts an
explicit project ID at initialization. The Admin SDK can set custom user claims,
and a later client sign-in receives those claims in its ID token. A local setup
helper can therefore create a deterministic Pro user without a service-account
credential. The helper must set a matching `demo-` project ID before Admin SDK
initialization so it cannot fall back to a live project.

Sources:

- [Admin SDK connection to the Auth emulator](https://firebase.google.com/docs/emulator-suite/connect_auth#admin_sdks)
- [Custom claims propagation](https://firebase.google.com/docs/auth/admin/custom-claims#propagate_custom_claims_to_the_client)

## Firestore emulator

The Firestore emulator connection for an Android emulator is `10.0.2.2:8080`. The emulator clears its database contents when it shuts down. The Firestore SDK's offline cache is not cleared automatically, so a clean emulator database can still produce stale client reads. Firebase recommends disabling local persistence for emulator use or clearing the app's data between runs.

Source: [Firestore emulator connection and cache warning](https://firebase.google.com/docs/emulator-suite/connect_firestore#instrument_your_app_to_talk_to_the_emulator)

The Firestore emulator exposes an explicit flush endpoint. For this project ID:

```sh
curl -X DELETE \
  http://localhost:8080/emulator/v1/projects/pantas-dev-090126/databases/%28default%29/documents
```

The documented endpoint uses `(default)` in the URL. The encoded form above is equivalent for shell clients that encode parentheses.

Source: [Firestore emulator clear endpoint](https://firebase.google.com/docs/emulator-suite/connect_firestore#clear_your_database_between_tests)

Firebase supports shared Auth, Firestore, and Storage baselines through `firebase emulators:export` and `--import`. `firebase emulators:exec` starts the configured emulators, runs a script, and stops them when the script finishes. `--import` overwrites emulator memory with the imported baseline. This is the cleanest runner boundary for CI, but it does not clear Android app data or the Firestore SDK cache.

Sources:

- [Emulator import/export and `emulators:exec`](https://firebase.google.com/docs/emulator-suite/install_and_configure#export_and_import_emulator_data)
- [Firestore emulator import/export](https://firebase.google.com/docs/emulator-suite/connect_firestore#import_and_export_data)

The emulator is not a full production Firestore oracle. Firebase documents differences in concurrent transaction behavior, compound-index enforcement, and production limits. A local suite can claim rules and basic read/write behavior. It cannot claim production index planning, limit enforcement, or all transaction behavior.

Source: [Firestore emulator production differences](https://firebase.google.com/docs/emulator-suite/connect_firestore#how_the_cloud_firestore_emulator_differs_from_production)

## Callable Functions

The candidate's Functions gateways select region `asia-southeast1`, so the local client must configure the same region before calling the emulator. Firebase's callable client SDK automatically includes Auth, FCM, and App Check tokens when they are available. A callable function is not the same wire contract as an ordinary HTTP function. The suite must use `httpsCallable` or implement Firebase's callable protocol exactly.

Sources:

- [Calling callable Functions](https://firebase.google.com/docs/functions/callable)
- [Callable protocol reference](https://firebase.google.com/docs/functions/callable-reference)
- [Candidate Functions emulator connection](https://firebase.google.com/docs/emulator-suite/connect_functions#instrument_your_app_for_callable_functions)

The Functions emulator serves local traffic over unencrypted HTTP. Android 9 and later disable cleartext communication by default. Firebase says an Android network-security configuration may be needed to allow the local emulator host. The candidate manifest has no explicit cleartext allowance or network-security configuration, so a local callable E2E run must verify this before relying on the Functions path.

Source: [Functions emulator Android cleartext warning](https://firebase.google.com/docs/emulator-suite/connect_functions#instrument_your_app_for_callable_functions)

The candidate's sensitive callables use `enforceAppCheck: true`, and some use replay-token consumption. A local Functions run can exercise callable routing, auth claims, handler responses, and emulator cross-service triggers. It cannot honestly prove production App Check enforcement, replay protection, cloud latency, or production Functions behavior. The emulator is documented as beta, and Firebase calls out production differences for some trigger and dispatch behavior.

## App Check

Firebase documents that an App Check-enforced backend will not accept ordinary emulator or CI traffic because those environments are not valid attested devices. The supported local path is a debug build using the App Check debug provider. The app prints a debug token, and that token must be registered in Firebase Console. The token grants backend access without device attestation and must stay private.

Source: [App Check debug provider for Android](https://firebase.google.com/docs/app-check/android/debug-provider)

The candidate selects `AndroidDebugProvider` for dev and staging and `AndroidPlayIntegrityProvider` for prod. This supports a local debug-provider path for a deployed dev or staging backend after a token is registered. It does not make a local emulator a Play Integrity device. The production Play Integrity path needs the external Play Console and Firebase setup described in the repository's contributor instructions.

Do not claim that a local Emulator Suite run validates production App Check. Firebase documents the debug-provider exception for emulator and CI environments, but it does not document local production-grade attestation. Keep the local claim to callable and data behavior unless the test explicitly uses a registered debug token against a deployed backend.

## Google Sign-In

The Auth emulator can test authentication flows and can serve mock third-party sign-in pages for SDK-driven IDP flows. Firebase notes that those pages can appear in mobile web views. The candidate instead uses the native `google_sign_in` plugin to obtain a Google ID token, then passes that token to Firebase Auth. That native path still depends on Google Play services, an enabled Google provider, the Android package's SHA-1 registration, and current OAuth data in `google-services.json`.

Sources:

- [Auth emulator provider and mobile web-view behavior](https://firebase.google.com/docs/emulator-suite/connect_auth#testing_firebase_sdk-driven_idp_flows)
- [Firebase Google Sign-In Android setup](https://firebase.google.com/docs/auth/android/google-signin)

Therefore an emulator-only Auth suite may claim anonymous Auth, Auth-emulator account flows, and injected credential flows that the harness controls. It must not claim native Google Sign-In works unless it runs the native chooser on a configured device and verifies the resulting credential. A real Google Sign-In journey remains a dev-project or Play-device check.

## Honest release-E2E claims

The balanced suite can honestly claim:

- Flutter widget and app journeys run on an Android emulator or device through `integration_test`.
- ADB force-stop followed by explicit activity start exercises a new Android app process while keeping app data.
- Auth, Firestore, callable Functions, and cross-service rules can be tested against local emulators after endpoint wiring is added.
- Auth and Firestore baselines can be reset through documented REST endpoints or imported with the Firebase CLI.
- A signed or release-like APK can be tested for process interruption through an external ADB runner, independent of Flutter's in-test rebuild APIs.

The suite must not claim:

- `pumpWidget` or `restartAndRestore` is Android process death.
- A Flutter `integration_test` run by itself validates a signed release AAB or a Play-installed build.
- `am force-stop` clears app data, signs out Firebase Auth, or clears Firestore's offline cache.
- Local emulators prove Play Integrity, production App Check enforcement, production Functions behavior, production Firestore indexing, or all production transaction limits.
- Auth-emulator credentials are valid against production Firebase.
- Native Google Sign-In is covered by an Auth-emulator-only journey.

## Open limits for the design

1. The candidate needs an explicit test-only emulator endpoint switch for Auth, Firestore, and Functions. No such switch exists at this SHA.
2. The candidate needs an Android cleartext network configuration for local Functions traffic, or a verified equivalent. The current manifest does not declare one.
3. The runner must choose a reset policy per journey. `pm clear` resets local app state. Auth and Firestore REST flushes reset server emulator state. Firestore SDK persistence needs its own handling.
4. Debug App Check tokens, Firebase project settings, Google provider setup, SHA-1 fingerprints, Play Integrity enrollment, and Play installation are external state. They are not proven by this repository checkout.
5. The release-E2E plan and spec were not present in this worktree. The 2026-09-04 decision log is the available design authority for the balanced scope. This note records platform evidence only.
