# Firebase Runtime Auth R2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans. Do not use internal subagents; the user coordinates separate web chats manually.

**Goal:** Wire the existing Auth domain to Firebase Auth, Google Sign-In, and callable Functions while preserving local-first fail-open startup.

**Architecture:** Keep Auth responsible for identity and account lifecycle only. Firebase Core availability decides whether live adapters are installed, but the app always receives a non-throwing AuthRepository provider. Existing-account cloud reconciliation is removed from Auth and remains owned by Wave 2E Sync.

**Tech Stack:** Flutter/Dart, Riverpod, firebase_auth 6.x, google_sign_in 7.2.x, cloud_functions 6.x, Firebase Functions v2/TypeScript.

**Spec:** `docs/superpowers/specs/2026-08-28-firebase-runtime-auth-r2-design.md`

## Global Constraints

- Base exactly `33e0ae29e783e3d6fdc4fa62ecb90121e6cae609`.
- Assigned branch `codex/firebase-runtime-auth-r2`.
- Do not modify content corpus paths, RevenueCat ownership, Android signing/release infrastructure, Firestore Sync engine/rules, or telemetry identity.
- Do not deploy Firebase Functions or mutate Firebase/Google Console.
- Anonymous Free and named Free remain local-only; named Pro alone is Sync-eligible.
- Self-service data export remains deferred.
- Use TDD when local execution is available; if the web runtime cannot execute, implement narrowly and report verification as unavailable for later manual terminal verification.

---

### Task 1: Firebase Auth adapter and reauthentication seam

**Files:**
- Create: `lib/core/auth/firebase_auth_gateway.dart`
- Modify: `lib/core/auth/auth_repository.dart`
- Test: `test/core/auth/firebase_auth_gateway_test.dart`
- Test: `test/core/auth/auth_repository_privacy_test.dart`

**Interfaces:**
- Extend `AuthGateway` with `Future<void> reauthenticateWithGoogleCredential(GoogleAuthTokens tokens)`.
- `FirebaseAuthGateway implements AuthGateway`.

- [ ] Add focused tests for `User -> AuthSession` mapping, auth-state mapping, anonymous sign-in, Google credential link/sign-in, Firebase error-code forwarding, missing-current-user behavior, and reauthentication.
- [ ] Make the privacy test prove stale deletion invokes reauthentication and never ordinary credential sign-in.
- [ ] Implement Google credentials with `GoogleAuthProvider.credential(idToken: tokens.idToken, accessToken: tokens.accessToken)` and use Firebase Auth APIs from the design.
- [ ] Forward `FirebaseAuthException.code` through `AuthGatewayException` unchanged.
- [ ] Run only the adapter/privacy focused tests when execution is available.
- [ ] Commit: `feat(auth): add Firebase Auth gateway`

### Task 2: Google Sign-In v7 adapter

**Files:**
- Create: `lib/core/auth/firebase_google_sign_in_gateway.dart`
- Test: `test/core/auth/firebase_google_sign_in_gateway_test.dart`

**Interfaces:**
- Produces a `GoogleSignInGateway` that returns `GoogleAuthTokens(idToken: ..., accessToken: null)`.

- [ ] Add tests proving initialization occurs exactly once, authentication uses the v7 authenticate path, the ID token is returned, cancellation maps to null, non-cancel errors remain failures, ordinary sign-out uses signOut, and no disconnect/access-token authorization path is used.
- [ ] Implement lazy/once initialization around `GoogleSignIn.instance.initialize()` with no hard-coded `serverClientId`.
- [ ] Catch only `GoogleSignInExceptionCode.canceled` as cancellation.
- [ ] Run the focused Google gateway test when execution is available.
- [ ] Commit: `feat(auth): add Google sign-in gateway`

### Task 3: Callable Functions client and backend hardening

**Files:**
- Create: `lib/core/auth/firebase_auth_functions_gateway.dart`
- Modify: `functions/src/_audit.ts`
- Modify: `functions/src/recordSignInEvent.ts`
- Modify: `functions/src/deleteAccount.ts`
- Modify: `functions/test/static.test.mjs` or add a narrowly named Auth Functions test if static parsing is insufficient.
- Test: `test/core/auth/firebase_auth_functions_gateway_test.dart`

**Interfaces:**
- `FirebaseAuthFunctionsGateway implements AuthFunctionsGateway`.
- Region is exactly `asia-southeast1`.

- [ ] Test exact callable names, region, empty request shape, export URL parsing, malformed export response, and callable error translation.
- [ ] Replace plain Auth/permission errors in `assertNamedUser` with structured `HttpsError` values.
- [ ] Make `recordSignInEvent` idempotently ensure `/users/{uid}` exists with initial `createdAt` before writing the sign-in audit event. Do not write study progress or Pro state.
- [ ] Preserve the existing `onUserCreated` Firestore trigger semantics for first root creation.
- [ ] Change recent-login backend rejection to a structured HttpsError carrying semantic reason `requires-recent-login`.
- [ ] Import Admin Auth in `deleteAccount` and call `deleteUser(uid)` only after Firestore/shared/storage cleanup succeeds.
- [ ] Keep export backend behavior unchanged; export is not activated in UI.
- [ ] Run focused Dart Functions-gateway tests and `cd functions && npm test` when execution is available.
- [ ] Commit: `fix(auth): harden account functions`

### Task 4: Remove cloud reconciliation from Auth collision flow

**Files:**
- Modify: `lib/core/auth/auth_repository.dart`
- Modify: `lib/core/auth/sign_in_result.dart`
- Modify: `test/core/auth/auth_repository_collision_test.dart`
- Modify: `test/core/auth/auth_repository_google_test.dart` as needed.

**Interfaces:**
- `SignInResult.switchedToExisting()` becomes an identity result with no meaningful-cloud/local fields.
- `CloudProgressGateway` is no longer an `AuthRepository` dependency.

- [ ] Update tests so credential collision proves: transition prepare -> Firebase anonymous sign-out -> existing Google credential sign-in -> sign-in/root callable; no Firestore/cloud meaningful-data read occurs.
- [ ] Preserve local state on account switch; do not call `wipeAll()`.
- [ ] Preserve fallback re-anonymization if the existing credential sign-in fails after the old anonymous user has been signed out.
- [ ] Remove `CloudProgressGateway`/`EmptyCloudProgressGateway` from the Auth domain if no Auth consumer remains. Do not delete the separate Sync cloud-progress implementation; Wave 2E owns Sync.
- [ ] Run Auth repository Google/collision tests when execution is available.
- [ ] Commit: `refactor(auth): separate identity from cloud reconciliation`

### Task 5: Provider wiring and fail-open anonymous bootstrap

**Files:**
- Create: `lib/app/auth_bootstrap.dart`
- Modify: `lib/core/auth/providers.dart`
- Modify: `lib/app/bootstrap.dart`
- Test: `test/app/auth_bootstrap_test.dart`
- Test: `test/core/auth/providers_test.dart`

**Interfaces:**
- The ProviderContainer must always receive a concrete, non-throwing `authRepositoryProvider` override.
- Live repository uses `FirebaseAuthGateway`, `FirebaseGoogleSignInGateway`, `FirebaseAuthFunctionsGateway`, `SyncLocalStateWiper`, and the Wave 2C transition gateway default.

- [ ] Add tests for Firebase configured/unavailable construction, cached named user, cached anonymous user, empty Auth session, anonymous creation failure, and provider non-throwing behavior.
- [ ] Add a safe unavailable Auth gateway/repository surface returning signed-out state and stable `firebase-unavailable` for explicit remote Auth operations.
- [ ] Retain the result from `bootstrapFirebase(flavor)` in `bootstrap.dart`.
- [ ] Install Auth provider overrides during ProviderContainer construction.
- [ ] After container creation, call an Auth bootstrap helper that attempts `ensureAnonymous()` only when Firebase was configured and catches failures so `runApp()` is never blocked.
- [ ] Do not instantiate the dormant telemetry Auth identity listener.
- [ ] Correct the stale bootstrap comment claiming Firebase is not configured.
- [ ] Run bootstrap/provider focused tests when execution is available.
- [ ] Commit: `feat(auth): wire fail-open auth runtime`

### Task 6: Sign-out hardening and Account UI behavior

**Files:**
- Modify: `lib/core/auth/auth_repository.dart`
- Modify: `lib/features/settings/presentation/pages/account_page.dart`
- Modify: `test/core/auth/auth_repository_sign_out_test.dart`
- Test: `test/features/settings/presentation/account_page_test.dart`

**Interfaces:**
- Account UI treats `user == null` as local-only regardless of whether a Firebase anonymous session currently exists.

- [ ] Add sign-out test proving Google sign-out failure still attempts `ensureAnonymous()` after Firebase sign-out succeeds.
- [ ] Keep prepare -> wipe -> Firebase sign-out ordering unchanged.
- [ ] Make cancelled Google sign-in a no-error UI outcome.
- [ ] Make switched-to-existing a successful identity outcome with no B3 prompt in this wave.
- [ ] Replace the sign-in copy with local-only/Pro-aware wording that does not promise backup for named Free users.
- [ ] Replace sign-out copy so it does not promise universal restore.
- [ ] Run focused sign-out and Account page tests when execution is available.
- [ ] Commit: `fix(auth): harden account UI lifecycle`

### Task 7: Privacy/setup documentation and final focused verification

**Files:**
- Modify: `docs/PRIVACY.md`
- Modify: `docs/firebase-setup.md`
- Test/verify all files from Tasks 1-6.

- [ ] Remove stale v1 wording claiming Settings has self-service data export; preserve the approved DPO-request path.
- [ ] Add Anonymous Authentication as a required provider for every shipping Firebase project.
- [ ] Document the per-flavor Web OAuth client and `google-services.json` `client_type: 3` requirement.
- [ ] Do not claim console settings have already been enabled/deployed.
- [ ] Run the focused Flutter set:

```bash
flutter test --no-test-assets \
  test/core/auth/auth_state_test.dart \
  test/core/auth/providers_test.dart \
  test/core/auth/auth_repository_test.dart \
  test/core/auth/auth_repository_google_test.dart \
  test/core/auth/auth_repository_collision_test.dart \
  test/core/auth/auth_repository_sign_out_test.dart \
  test/core/auth/auth_repository_privacy_test.dart \
  test/core/auth/firebase_auth_gateway_test.dart \
  test/core/auth/firebase_google_sign_in_gateway_test.dart \
  test/core/auth/firebase_auth_functions_gateway_test.dart \
  test/app/auth_bootstrap_test.dart \
  test/features/settings/presentation/account_page_test.dart
```

- [ ] Run Functions tests:

```bash
cd functions && npm test
```

- [ ] Run non-rewriting Dart format check on all changed Dart/test files.
- [ ] Run `git diff --check 33e0ae29e783e3d6fdc4fa62ecb90121e6cae609...HEAD`.
- [ ] Run `dart run tool/check_no_ai_attribution.dart`.
- [ ] Confirm no unexpected changed paths and no generated files are tracked.
- [ ] Commit docs only if they were not included naturally with an earlier task: `docs(firebase): update auth setup contract`.

## Required handoff

Report starting SHA, final pushed SHA, worker commits, exact changed paths, adapter contracts, collision behavior, anonymous bootstrap behavior, deletion/re-auth behavior, backend root/deletion behavior, UI copy disposition, all focused test totals, Functions test totals, format result, diff-check result, no-AI result, final status, deviations, and confirmation that no PR/merge/Actions/Firebase/Play/Sanity mutation occurred.

Classify exactly:

`WAVE 2D AUTH RUNTIME VERIFIED`

or

`WAVE 2D AUTH RUNTIME NOT VERIFIED`
