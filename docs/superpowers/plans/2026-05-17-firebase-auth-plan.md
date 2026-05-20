# Firebase + Auth Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Firebase bootstrap, anonymous-first auth, Google account linking seams, sign-out-to-fresh-anonymous behavior, App Check/Crashlytics wiring, Firestore rules, and privacy callable scaffolding for Android v1.

**Architecture:** The Flutter app uses one `lib/core/auth/` module as the only app-facing auth boundary. Firebase SDK wrappers live behind small interfaces so unit tests use fakes and later iOS Apple Sign In is additive. External Firebase project setup is isolated to generated options and console steps; code paths that can be tested without console access are implemented first.

**Tech Stack:** Flutter, Riverpod, Firebase Core/Auth/App Check/Crashlytics/Functions/Firestore, Google Sign-In, mocktail, Node 20 Firebase Functions, Firestore rules.

**Target spec:** `docs/superpowers/specs/2026-05-16-firebase-auth-design.md`

**Date:** 2026-05-17

**Size:** L

---

## Open Questions

- The target spec says the roadmap entry expects `currentUserProvider` exposing `User?`, while the design body defines an app-level `AuthUser?`/`AuthState` surface. Tentative choice: expose app-level `AuthUser?` so Firebase types stay isolated to `auth_repository.dart`, and add a provider name compatible with the roadmap.
- The repo already has a `staging` flavor, while Spec 1 names only dev and prod Firebase projects. Tentative choice: keep the existing flavor enum for compatibility, but map staging to dev Firebase behavior until a later roadmap item removes or formalizes it.
- `pubspec.yaml` already includes `sign_in_with_apple`, but Apple Sign In is deferred. Tentative choice: leave the dependency untouched to avoid unrelated churn, but do not import or initialize Apple-specific auth code.

## External Blockers

- **Firebase projects:** Create `cse-cet-reviewer-dev` and `cse-cet-reviewer-prod` in Firebase Console, region `asia-southeast1`, with Auth, Firestore, App Check, Functions, Crashlytics, Remote Config, Messaging, and Storage enabled.
- **FlutterFire generation:** Run `flutterfire configure` after `firebase login` to generate `lib/firebase_options_dev.dart`, `lib/firebase_options_prod.dart`, `android/app/src/dev/google-services.json`, and `android/app/src/prod/google-services.json`.
- **Android package registration:** Register Android apps for `com.aerol.csecet.dev` and `com.aerol.csecet` or update the package IDs if the product owner chooses to keep the current `com.aedwon.csecetreviewer` namespace.
- **Google Sign-In provider:** Enable Google in Firebase Auth for both projects and add the debug/release SHA fingerprints from the developer machines and Play signing.
- **App Check:** Register debug tokens for dev workstations/CI in the dev project, then configure Play Integrity for prod after the Play Console app is available.
- **Firestore/Storage enforcement:** Toggle App Check enforcement on for Firestore and Storage in both Firebase projects after the debug/prod providers are registered.
- **Cloud Functions secrets:** Set `REVENUECAT_SECRET_KEY` with `firebase functions:secrets:set REVENUECAT_SECRET_KEY` before deploying deletion functions.
- **Cloud Logging retention:** Update the audit log bucket retention to 400 days in Google Cloud console or via `gcloud`.

## Phase 1: Bootstrap & Configuration

### Step 1.1: Firebase config selector and boot seam

**Goal:** Add a boot-time Firebase initializer that selects dev/prod options by `Flavor`, but can be disabled in tests or while generated options are missing.

**Files:**
- Create: `lib/app/firebase_bootstrap.dart`
- Modify: `lib/app/bootstrap.dart`
- Test: `test/app/firebase_bootstrap_test.dart`

**Test first:**
- `firebaseConfigForFlavor returns null until generated options exist`
- `bootstrapFirebase skips initialization when options are unavailable`
- `bootstrapFirebase activates debug App Check for dev and Play Integrity for prod through an injected adapter`

**Implementation notes:**
- Use an injectable `FirebaseBootAdapter` so tests do not initialize real Firebase.
- Do not create placeholder API keys. Return `null` from the selector until `firebase_options_dev.dart`/`prod.dart` exist.
- Keep staging mapped to dev behavior.

### Step 1.2: Android flavor and Firebase file placeholders

**Goal:** Align Android flavor names and application IDs with the Firebase project layout without committing generated secrets.

**Files:**
- Modify: `android/app/build.gradle.kts`
- Create: `android/app/src/dev/.gitkeep`
- Create: `android/app/src/prod/.gitkeep`
- Test: `test/tool/firebase_config_layout_test.dart`

**Test first:**
- `android Gradle config defines dev and prod flavors`
- `dev flavor uses com.aerol.csecet.dev`
- `prod flavor uses com.aerol.csecet`
- `repo does not commit google-services json placeholders`

**Implementation notes:**
- Remove or leave staging only if doing so does not break existing entrypoints. Because `main_staging.dart` exists, prefer leaving staging but mapping it to a dev-like package suffix.
- Do not invent `google-services.json`.

### Step 1.3: Firebase emulator and rules baseline

**Goal:** Add Firebase emulator config and deny-by-default Firestore rules with owner-only named-user access.

**Files:**
- Create: `firebase.json`
- Create: `firestore.rules`
- Create: `storage.rules`
- Test: `test/tool/firebase_rules_layout_test.dart`

**Test first:**
- `firestore.rules denies audit_logs client access`
- `firestore.rules rejects anonymous users by sign_in_provider`
- `firebase.json points at firestore.rules and local emulators`

**Implementation notes:**
- Rules tests using the Firebase emulator are a later external-capable layer; this step adds static guard tests so CI can run without Node/Firebase CLI.

## Phase 2: Anonymous Auth Foundation

### Step 2.1: Auth domain models and provider surface

**Goal:** Add app-level auth types and Riverpod providers without leaking Firebase SDK user types outside the repository module.

**Files:**
- Create: `lib/core/auth/auth.dart`
- Create: `lib/core/auth/auth_state.dart`
- Create: `lib/core/auth/auth_user.dart`
- Create: `lib/core/auth/sign_in_result.dart`
- Create: `lib/core/auth/providers.dart`
- Test: `test/core/auth/auth_state_test.dart`
- Test: `test/core/auth/providers_test.dart`

**Test first:**
- `AuthState.fromUser maps null to signedOut`
- `AuthState.fromUser maps anonymous uid to anonymous state`
- `AuthState.fromUser maps named user to signedIn with pro claim default false`
- `currentUserProvider returns null for unknown and signedOut`
- `isSignedInProvider is true only for named users`
- `isAnonymousProvider is true only for anonymous users`

**Implementation notes:**
- Use plain immutable Dart classes/sealed classes unless codegen is already required; avoid adding generated files for auth unless tests show a strong need.
- Include a `bool isPro` on `AuthUser` sourced from custom claims later, but do not create Firestore entitlement fields.

### Step 2.2: AuthRepository anonymous flow

**Goal:** Implement `ensureAnonymous()` around an injected auth gateway.

**Files:**
- Create: `lib/core/auth/auth_repository.dart`
- Test: `test/core/auth/auth_repository_test.dart`

**Test first:**
- `ensureAnonymous signs in when there is no current user`
- `ensureAnonymous is no-op for an anonymous current user`
- `ensureAnonymous is no-op for a named current user`
- `authState emits anonymous after anonymous sign-in`

**Implementation notes:**
- Only this repository file imports `firebase_auth`.
- Use `FirebaseAuthGateway` as the concrete adapter and an `AuthGateway` interface for tests.

## Phase 3: Google Sign-In + Anonymous-to-Named Migration

### Step 3.1: Google sign-in link path

**Goal:** Implement the clean anonymous-to-Google link path and sign-in audit callback.

**Files:**
- Modify: `lib/core/auth/auth_repository.dart`
- Create: `lib/core/auth/auth_gateways.dart`
- Test: `test/core/auth/auth_repository_google_test.dart`

**Test first:**
- `signInWithGoogle returns cancelled when the native account picker returns null`
- `signInWithGoogle links credential to the current anonymous user`
- `signInWithGoogle calls recordSignInEvent after successful link`
- `signInWithGoogle returns failed with redacted FirebaseAuthException code on unexpected auth error`

**Implementation notes:**
- Inject `GoogleSignInGateway` and `FunctionsGateway` so tests do not open native UI.
- Do not add paywall UI; Spec 7 owns paywall surfaces.

### Step 3.2: Collision fallback result

**Goal:** Implement B3-lite collision behavior up to returning the decision state; SyncCoordinator execution stays behind interfaces.

**Files:**
- Create: `lib/core/auth/local_state_wiper.dart`
- Create: `lib/core/auth/sync_coordinator.dart`
- Modify: `lib/core/auth/auth_repository.dart`
- Test: `test/core/auth/auth_repository_collision_test.dart`

**Test first:**
- `credential-already-in-use signs out anonymous user then signs in with credential`
- `collision result includes local and cloud meaningful-data flags`
- `collision calls recordSignInEvent after fallback sign-in`
- `failure between signOut and signInWithCredential calls ensureAnonymous and preserves local data`

**Implementation notes:**
- `SyncCoordinator` and `LocalStateWiper` are interfaces only in Spec 1.
- Repository returns `SignInResult.switchedToExisting`; UI branching and merge prompt can land with Settings/Paywall unless the spec explicitly requires the prompt now.

## Phase 4: Sign-Out and Privacy Callables

### Step 4.1: Sign-out wipes local state before re-anonymizing

**Goal:** Add repository sign-out behavior that wipes local user data, signs out Firebase/Google, then creates a fresh anonymous user.

**Files:**
- Modify: `lib/core/auth/auth_repository.dart`
- Test: `test/core/auth/auth_repository_sign_out_test.dart`

**Test first:**
- `signOut calls LocalStateWiper.wipeAll before FirebaseAuth.signOut`
- `signOut calls Google sign-out`
- `signOut creates a fresh anonymous session after sign-out`
- `signOut attempts ensureAnonymous even when Google sign-out fails`

**Implementation notes:**
- Confirmation dialogs and settings rows are Spec 8; repository assumes confirmation already happened.

### Step 4.2: Export and delete account callables

**Goal:** Add Flutter repository methods for self-service export and deletion with re-auth seam.

**Files:**
- Modify: `lib/core/auth/auth_repository.dart`
- Test: `test/core/auth/auth_repository_privacy_test.dart`

**Test first:**
- `exportData calls exportData callable and returns a Uri`
- `exportData rejects missing or malformed downloadUrl`
- `deleteAccount reauthenticates when last sign-in is older than five minutes`
- `deleteAccount calls callable then wipes local state`

**Implementation notes:**
- Use injected functions/google gateways for tests.
- Do not add Legal/Settings UI in Spec 1 beyond callable capability.

## Phase 5: App Check + Crashlytics

### Step 5.1: App Check activation and Crashlytics user keys

**Goal:** Wire Firebase App Check and Crashlytics through testable adapters during bootstrap/auth transitions.

**Files:**
- Modify: `lib/app/firebase_bootstrap.dart`
- Create: `lib/core/telemetry/crash_reporting.dart`
- Test: `test/app/firebase_bootstrap_test.dart`
- Test: `test/core/telemetry/crash_reporting_test.dart`

**Test first:**
- `dev bootstrap activates debug Android App Check`
- `prod bootstrap activates Play Integrity Android App Check`
- `CrashReporter clears user id for signedOut`
- `CrashReporter sets anonymous uid and named uid without email`

**Implementation notes:**
- Do not include iOS DeviceCheck/App Attest activation in v1 code.

## Phase 6: Cloud Functions Scaffold

### Step 6.1: Functions package and callable skeletons

**Goal:** Add Node 20 Firebase Functions source for export, deletion, sign-in audit, and scheduled cleanup with unit-testable helpers.

**Files:**
- Create: `functions/package.json`
- Create: `functions/tsconfig.json`
- Create: `functions/src/index.ts`
- Create: `functions/src/_audit.ts`
- Create: `functions/src/exportData.ts`
- Create: `functions/src/deleteAccount.ts`
- Create: `functions/src/recordSignInEvent.ts`
- Create: `functions/src/onUserCreated.ts`
- Create: `functions/src/cleanupOrphanAnons.ts`
- Create: `functions/src/purgeOldExports.ts`
- Create: `functions/src/purgeOldAuditLogs.ts`
- Test: `functions/test/audit.test.ts`
- Test: `functions/test/callables.test.ts`

**Test first:**
- `recordSignInEvent rejects anonymous context`
- `exportData rejects anonymous context`
- `deleteAccount rejects stale auth_time`
- `writeAuditLog writes Cloud Logging payload and Firestore audit_logs doc through injected sinks`

**Implementation notes:**
- If `npm install` is blocked by network, commit package/source/tests and report dependency installation as blocked.
- Keep RevenueCat deletion behind an injected HTTP client so tests do not call the network.

## Phase 7: CI and Documentation

### Step 7.1: CI wiring for auth and backend checks

**Goal:** Add CI commands for Flutter auth tests, static Firebase config checks, and backend tests when dependencies are installed.

**Files:**
- Modify: `.github/workflows/ci.yml`
- Modify: `.github/workflows/main.yml`
- Test: local command execution

**Test first:**
- `flutter test test/core/auth test/app/firebase_bootstrap_test.dart test/tool`
- `flutter analyze`
- `cd functions && npm test` if dependencies are available

**Implementation notes:**
- Keep backend job separate so Flutter unit tests remain fast and clear.

### Step 7.2: Manual setup documentation

**Goal:** Document Firebase setup steps that cannot be completed from the repo.

**Files:**
- Create or modify: `CONTRIBUTING.md`
- Test: `test/tool/firebase_setup_docs_test.dart`

**Test first:**
- `CONTRIBUTING.md documents flutterfire configure`
- `CONTRIBUTING.md documents App Check debug token registration`
- `CONTRIBUTING.md documents Play Integrity as prod-only Android setup`

**Implementation notes:**
- Include no API keys or generated token examples.

## Self-Review

- **Placeholder scan:** No unfinished placeholder markers are required to execute the non-blocked steps. Generated Firebase files are explicitly listed as external blockers.
- **Scope check:** The plan is limited to Spec 1. Paywall UI, Settings UI, SyncCoordinator implementation, Sanity content, RevenueCat entitlements, notifications, and iOS Apple Sign In are excluded.
- **TDD integrity:** Every code step names tests to write before implementation and can be committed independently.
- **External blocker consistency:** Console auth, `flutterfire configure`, Play Integrity registration, debug token registration, secrets, and retention changes are marked skippable.
