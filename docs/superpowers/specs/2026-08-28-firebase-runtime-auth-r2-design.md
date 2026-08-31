# Firebase Runtime Auth R2 Design

## Goal

Make the existing Pantas authentication domain use real Firebase Authentication, Google Sign-In, and callable Functions without making Firebase availability a prerequisite for local studying.

## Base

This design targets `codex/firebase-runtime-integration` at `33e0ae29e783e3d6fdc4fa62ecb90121e6cae609`.

Wave 1 already established Firebase Core, App Check, telemetry consent, and fail-open Firebase initialization. Wave 2C already established `AccountTransitionGateway`, the complete local account-state wipe, and opaque UID handling.

## Product boundary

The account model is fixed:

- Anonymous Free: local only.
- Named Free: local only.
- Named Pro: eligible for cloud backup/sync.
- Google sign-in establishes account identity. It does not itself activate cloud backup.
- Auth does not perform cloud/local B3 reconciliation. Wave 2E Sync owns that when a named account becomes sync-eligible.
- No record-level merge is introduced.

## Runtime architecture

### Firebase Auth adapter

Create `FirebaseAuthGateway` in `lib/core/auth/firebase_auth_gateway.dart`.

It implements `AuthGateway` with `FirebaseAuth.instance` and maps Firebase `User` to `AuthSession`:

- `uid` from `User.uid`
- `isAnonymous` from `User.isAnonymous`
- `email` from `User.email`
- `displayName` from `User.displayName`
- `photoUrl` from `User.photoURL`
- `lastSignInTime` from `User.metadata.lastSignInTime`
- `isPro` remains false in this wave; entitlement/claim integration belongs to Sync/Payments integration.

The adapter uses:

- `authStateChanges()`
- `signInAnonymously()`
- `currentUser.linkWithCredential(...)`
- `signInWithCredential(...)`
- `currentUser.reauthenticateWithCredential(...)`
- `signOut()`

Add `reauthenticateWithGoogleCredential(GoogleAuthTokens tokens)` to the `AuthGateway` contract. `AuthRepository.deleteAccount()` must use this operation for stale authentication instead of ordinary sign-in.

FirebaseAuthException codes are forwarded as stable `AuthGatewayException.code` values. Adapter-owned impossible states use stable Pantas codes such as `missing-current-user` and `missing-user-credential-result`.

### Google Sign-In v7 adapter

Create `FirebaseGoogleSignInGateway` in `lib/core/auth/firebase_google_sign_in_gateway.dart`.

Use google_sign_in 7.x semantics:

- `GoogleSignIn.instance`
- awaited `initialize()` exactly once
- `authenticate()` for interactive authentication
- `account.authentication.idToken`
- no Google API authorization scopes
- no access-token authorization request
- `GoogleSignInExceptionCode.canceled` maps to the existing `null` cancellation result
- ordinary logout uses `signOut()`, never `disconnect()`

Do not hard-code a Web OAuth client ID in Dart. Android must derive the Web client from the flavor's ignored `google-services.json` containing a `client_type: 3` OAuth client. That external configuration is verified separately.

### Callable Functions adapter

Create `FirebaseAuthFunctionsGateway` in `lib/core/auth/firebase_auth_functions_gateway.dart` using `FirebaseFunctions.instanceFor(region: 'asia-southeast1')`.

Use the existing callable names:

- `recordSignInEvent`
- `deleteAccount`
- `exportData`

Self-service export remains deferred at v1. The adapter may preserve the existing interface, but no new UI or export workflow is added.

Translate callable exceptions into stable `AuthGatewayException` values when AuthRepository must act on them. In particular, backend recent-login failures must remain distinguishable from generic `internal` failures.

### Named account root

A named account gets a minimal `/users/{uid}` root document independently of Pro backup eligibility.

Keep this server-side. `recordSignInEvent` becomes idempotently responsible for ensuring the root exists with `createdAt` before recording the sign-in audit event. It must not write study progress or activate Sync.

The existing `onUserCreated` Firestore document-created trigger may continue to record the `accountCreated` audit event when the root is first created.

### AuthRepository collision boundary

Remove cloud reconciliation from `AuthRepository`.

`CloudProgressGateway` is no longer an AuthRepository dependency. A credential collision means:

1. prepare the account transition;
2. sign out the old anonymous Firebase identity;
3. sign in to the existing Google credential;
4. ensure/account-audit through the Auth callable;
5. return a simple `switchedToExisting` result.

The current device's local data is preserved. Auth does not read Firestore to determine meaningful cloud data and does not push or pull anything.

Change `SignInResult.switchedToExisting` so it no longer carries meaningful local/cloud booleans. Wave 2E observes the resulting Auth session and owns reconciliation when the account is actually Pro/sync-eligible.

### Fail-open Auth bootstrap

Create `lib/app/auth_bootstrap.dart`.

`bootstrap()` must retain `FirebaseBootstrapResult` instead of discarding it.

The provider container must always have a non-throwing AuthRepository override:

- Firebase configured: real Firebase Auth + Google + Functions adapters and the Wave 2C `SyncLocalStateWiper`.
- Firebase unavailable: a safe unavailable Auth gateway/repository that exposes signed-out/local-only state and throws stable `firebase-unavailable` only when a remote Auth action is explicitly attempted.

After the container exists, attempt anonymous Firebase creation only when Firebase Core was configured. Anonymous creation is best-effort and fail-open. A cached Firebase user must not be replaced. Anonymous sign-in failure must never block `runApp()` or local studying.

The Account UI must treat signed-out/Firebase-unavailable state as local-only and still render the sign-in affordance.

### Sign-out hardening

Keep the Wave 2C ordering:

`prepareForSignOut -> wipe local account state -> Firebase sign-out`.

Once Firebase sign-out succeeds, a Google sign-out failure must not strand the app with no Firebase identity. `ensureAnonymous()` must still be attempted. Do not change the already approved wipe-before-Firebase ordering in this wave.

### Account deletion

For stale auth:

1. get fresh Google credentials;
2. call Firebase `reauthenticateWithCredential` through the new gateway seam;
3. call `prepareForDeleteAccount`;
4. invoke `deleteAccount` callable;
5. wipe local account state;
6. finish local Firebase/Google sign-out cleanup;
7. create a fresh anonymous Firebase session best-effort.

The backend `deleteAccount` callable must:

- use structured `HttpsError` for expected auth/permission/recent-login failures;
- delete the user's Firestore tree and existing shared/storage artifacts as today;
- delete the Firebase Authentication user with Admin Auth only after server-side data cleanup succeeds.

Deleting the Auth identity last allows a failed cleanup to be retried by the still-existing account.

### Backend error structure

`assertNamedUser()` must throw `HttpsError('unauthenticated', ...)` or `HttpsError('permission-denied', ...)`, not plain `Error`.

The recent-auth check in `deleteAccount` must use a structured HttpsError. Preserve the semantic reason `requires-recent-login` in a form the Dart Functions adapter can deterministically translate back to `AuthGatewayException('requires-recent-login')`.

### UI/copy

The Account page must not promise backup merely because a user signs in.

Use local-only/Pro-aware wording. The sign-in area should state that progress remains on this device and that cloud backup is a Pro capability. The sign-out confirmation must not promise that every named account can restore cloud progress.

Google cancellation is not an error. A cancelled sign-in leaves the local-only screen unchanged without showing the connection-error message.

A `switchedToExisting` result is an identity success, not a signal for Auth to perform B3 reconciliation.

### Privacy/docs

Self-service export remains deferred. Correct stale Privacy copy that claims an in-app export exists.

Update Firebase setup documentation to explicitly require Anonymous Authentication alongside Google Authentication and to document the Web OAuth `client_type: 3` requirement for each flavor's `google-services.json`.

Correct stale bootstrap comments that still claim Firebase Core is not configured.

## External prerequisites

This implementation must not mutate Firebase/Google configuration. Before device validation the user must separately verify:

- Anonymous Authentication enabled in dev/staging/prod Firebase projects;
- Google Authentication enabled in each project;
- provider support email configured;
- correct SHA-1/SHA-256 fingerprints registered;
- a Web OAuth client exists per project;
- each flavor `google-services.json` contains the Web OAuth `client_type: 3` client;
- updated `recordSignInEvent` and `deleteAccount` Functions are deployed in `asia-southeast1`;
- existing Wave 1 App Check policy remains in force.

## Non-goals

Wave 2D does not implement:

- production Firestore Sync;
- `FirebaseFirestoreGateway` for Sync;
- B3 push/pull reconciliation;
- Pro entitlement/claim lifecycle;
- pending-queue completion;
- Firestore rules changes;
- Remote Config changes;
- telemetry identity activation;
- self-service data export;
- Android signing/release changes.

## Verification

Focused Flutter tests must cover Firebase Auth mapping/error behavior, Google Sign-In initialization/cancellation, callable region/names/error translation, fail-open anonymous bootstrap, collision identity switching without cloud queries, reauthentication before deletion, sign-out recovery, provider wiring, and Account UI outcomes.

Focused Node tests/static tests must cover structured HttpsError behavior, idempotent named-root creation, and Firebase Auth deletion ordering.

The implementation branch is not verified until local Flutter/Dart/Node verification, format checks, `git diff --check`, and the no-AI-attribution gate pass.