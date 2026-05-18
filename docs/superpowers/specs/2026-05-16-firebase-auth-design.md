# Spec 1 — Firebase + Auth (Design)

- **Status:** Draft, pending user review
- **Date:** 2026-05-16
- **Owner:** Aerol
- **Roadmap context:** First spec on the critical path of `2026-05-16-mvp-roadmap-design.md`. Soft launch target 2026-06-28, Android-only.
- **Dependencies:** None (greenfield)
- **Unblocks:** Specs 2 (Sanity), 3 (SyncCoordinator), 6 (Study Plan persistence), 7 (Paywall + RevenueCat), 8 (Settings/Privacy), 9 (Notifications)

---

## Purpose

Establish the foundational identity and backend wiring the rest of the app depends on:

1. Every install gets a Firebase identity (anonymous by default) so the app can attach analytics, FCM tokens, and Crashlytics user keys to a stable id without forcing sign-up.
2. Users can upgrade to a Google-named identity at the paywall, enabling cross-device sync and Pro purchase attribution.
3. The backend is locked down day-1 (App Check enforced both projects, owner-only Firestore rules, anonymous Firestore writes denied).
4. Users have self-service data export and account deletion paths that satisfy RA 10173.

---

## Scope

**In scope:**
- Firebase dev + prod project setup (one-time, manual).
- Flutter wiring: `firebase_core`, `firebase_auth`, `google_sign_in`, `firebase_app_check`, `cloud_functions`.
- `AuthRepository` + Riverpod providers in `lib/core/auth/`.
- Anonymous-on-launch flow.
- Google sign-in with `linkWithCredential` + collision fallback (B3-lite UX).
- Sign-out flow (wipe local + re-anonymize).
- Account deletion + data export as Cloud Functions.
- Audit logging via Cloud Logging + Firestore `audit_logs` collection.
- App Check enforcement (debug provider in dev, Play Integrity in prod).
- Firestore security rules (deny-by-default, owner-only, anonymous denied).
- Unit, integration (against emulators), and rules tests in CI.

**Out of scope:**
- Apple Sign In (deferred to v1.x; iOS pivot is a v1.x follow-up once Apple Developer enrollment is funded).
- Email/password auth.
- Phone-number auth.
- Multi-account on a single device (UI for switching between two signed-in users).
- Cloud-side merge of overlapping anon + cloud data (B3-lite picks one side; record-level merge is post-v1).
- Pro entitlement storage in Firestore (RevenueCat is the source of truth — Spec 7).
- Lesson/question/mock content (Sanity → Drift; Spec 2).
- SyncCoordinator logic (Spec 3). This spec defines the seams (`SyncCoordinator.pushLocalToCloud()`, `LocalStateWiper.wipeAll()`) but not the implementations.

---

## Key decisions (with rationale)

### D1 — Sign-in semantics: "save progress + buy Pro"
Anonymous users have the full feature set locally but **never** write to Firestore. Sign-in is forced at paywall checkout.

**Why:** (1) Avoids ~$80/mo Firestore baseline cost at 100k anon MAU on never-converting users; (2) RevenueCat receipts attach to Firebase uid — anon Pro purchase plus later sign-in with a different Google uid becomes a support landmine; (3) honors "no signup wall before first value" — anon users get the entire learning loop free.

### D2 — Anon → Google collision: B3-lite (prompt only when both sides have meaningful data)
At sign-in, `linkWithCredential` is attempted first. On `credential-already-in-use`, we sign out anon, sign into the existing Google uid, then branch on `(meaningfulCloudData, meaningfulLocalData)`:
- `(false, *)` — silent push local up.
- `(true, false)` — silent pull cloud down.
- `(true, true)` — show MergePromptPage; user picks one side.

**Why:** Avoids silent data loss (the B1 failure mode) while keeping the common reinstall path zero-friction. Implementation is one UI dialog + one branch — no record-level merge.

### D3 — Account deletion + data export: self-service via Cloud Functions
Settings exposes "Export my data" and "Delete my account" rows. Both call backend Cloud Functions. No email-request workflow.

**Why:** Solo founder cannot be the bottleneck for legal requests with SLA implications. Function logs serve as audit trail for NPC inquiries.

### D4 — Two Firebase projects: `cse-cet-reviewer-dev` + `cse-cet-reviewer-prod`
Separate projects, separate Firestore/Auth/App Check. CI/builds pick environment via `--dart-define=APP_ENV=dev|prod`. No staging.

**Why:** Single-project is unsafe once destructive Cloud Functions exist; a buggy local Function run can wipe real users. Staging without a QA team becomes dead-weight config burden. Dev project on Spark (free); prod on Blaze (~₱0/mo expected until significant scale).

### D5 — App Check enforced day-1 in both projects
Debug provider in dev (debug token registered per workstation); Play Integrity in prod. `enforceAppCheck: true` on every callable Function. Firestore enforcement toggled on in console for both projects.

**Why:** Surprise-at-launch is the worst failure mode; better to hit App Check edge cases on day 1 with no users than on 2026-06-28 with reviewers watching. Token replay protection (`consumeAppCheckToken: true`) is enabled on `deleteAccount` and `exportData` Functions only (not Firestore — would 10x latency).

### D6 — Sign-in entry points: paywall + passive Settings entry
Sign-in surfaces only at paywall checkout (mandatory there) and as one row in Settings. No milestone prompts, no banners.

**Why:** Honors no-signup-wall principle; "sign in to save your progress!" banners read as dark patterns. Conversion-driven prompts can be A/B'd in v1.x once we have data.

### D7 — Sign-out: wipe local Drift + drop to fresh anonymous session
Confirmation dialog, then `LocalStateWiper.wipeAll()`, `FirebaseAuth.signOut()`, `GoogleSignIn.signOut()`, `ensureAnonymous()`. Theme + locale prefs survive.

**Why:** Matches the colloquial meaning of "sign out" (removes my data from this device). Enables clean account-switching on shared devices. Simpler mental model than a hybrid "signed out but with data" state.

### D8 — Audit logging via Cloud Logging + Firestore `audit_logs`
Every privacy-sensitive Function (`exportData`, `deleteAccount`) and every successful sign-in linking event writes a structured Cloud Logging entry AND a `/audit_logs/{autoId}` Firestore doc (server-only via admin SDK). Retention: 400 days for Cloud Logging audit bucket, 730 days for Firestore via `purgeOldAuditLogs` scheduled function.

**Why:** Supports both fast support lookups ("when did I delete my account?") and durable DPA-compliance evidence (NPC expects controllers to demonstrate handling of deletion requests). Anonymous-only users get zero entries (no persistent identity to log against).

---

## Architecture

### Firebase project layout

| | Dev | Prod |
|---|---|---|
| Project id | `cse-cet-reviewer-dev` | `cse-cet-reviewer-prod` |
| Plan | Spark (free) | Blaze (pay-as-you-go; expected ₱0/mo at launch scale) |
| Region | `asia-southeast1` (Singapore) | `asia-southeast1` (Singapore) |
| Android applicationId | `com.aerol.csecet.dev` | `com.aerol.csecet` |
| App Check provider | Debug | Play Integrity |
| Cloud Functions | Emulated locally; deployed in prod only | Deployed |

**Services enabled both projects:** Authentication (Anonymous + Google), Cloud Firestore, App Check, Cloud Functions, Crashlytics, Remote Config, Cloud Messaging, Cloud Storage (for `/exports/`).

**Flutter wiring:**
- `flutterfire configure` run twice → produces `lib/firebase_options_dev.dart` and `lib/firebase_options_prod.dart`.
- Android product flavors `dev` and `prod` in `android/app/build.gradle.kts`, each with its own `google-services.json` under `android/app/src/{dev,prod}/`.
- `main.dart` reads `const APP_ENV = String.fromEnvironment('APP_ENV', defaultValue: 'dev')` and selects the matching options file.
- One root `firebase.json` configures the local emulator suite (Auth, Firestore, Functions, Storage).

### Auth provider stack + Riverpod

New module: `lib/core/auth/`.

```
lib/core/auth/
├── auth.dart                    // barrel
├── auth_repository.dart         // wraps FirebaseAuth + GoogleSignIn
├── auth_state.dart              // Freezed union
├── sign_in_result.dart          // Freezed union
├── local_state_wiper.dart       // interface (impl lives in Spec 3)
├── sync_coordinator.dart        // interface (impl lives in Spec 3)
└── providers.dart               // Riverpod providers
```

**Riverpod surface:**

| Provider | Type | Purpose |
|---|---|---|
| `authRepositoryProvider` | `Provider<AuthRepository>` | Singleton repository |
| `authStateProvider` | `StreamProvider<AuthState>` | Emits on every Firebase user change |
| `currentUserProvider` | `Provider<AuthUser?>` | Computed from authStateProvider |
| `isAnonymousProvider` | `Provider<bool>` | Convenience derivation |
| `isSignedInProvider` | `Provider<bool>` | Signed-in AND not anonymous |

**`AuthState` Freezed union:**
```dart
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.unknown() = _Unknown;       // pre-init
  const factory AuthState.anonymous({required String uid}) = _Anonymous;
  const factory AuthState.signedIn({
    required String uid,
    required String email,
    required String displayName,
    String? photoUrl,
  }) = _SignedIn;
  const factory AuthState.signedOut() = _SignedOut;   // transient, between sign-out and re-anon
}
```

**`SignInResult` Freezed union:**
```dart
@freezed
sealed class SignInResult with _$SignInResult {
  const factory SignInResult.linkedExisting() = _LinkedExisting;
  const factory SignInResult.switchedToExisting({
    required bool meaningfulCloudData,
    required bool meaningfulLocalData,
  }) = _SwitchedToExisting;
  const factory SignInResult.cancelled() = _Cancelled;
  const factory SignInResult.failed({required String reason}) = _Failed;
}
```

**`AuthRepository` public surface:**
- `Future<void> ensureAnonymous()` — called once at app boot. No-op if already signed in.
- `Future<SignInResult> signInWithGoogle()` — handles `linkWithCredential` + collision fallback.
- `Future<void> signOut()` — confirm-dialog gating happens in UI; this method assumes confirmation.
- `Future<void> deleteAccount()` — re-auth gate + calls `deleteAccount` Cloud Function.
- `Future<Uri> exportData()` — calls `exportData` Cloud Function, returns signed URL.

**Isolation invariant:** Only `auth_repository.dart` imports `firebase_auth` or `google_sign_in`. The rest of the app uses the Riverpod providers. Adding `sign_in_with_apple` (post-iOS-funding) is one extra method on `AuthRepository` and one extra button in the UI.

---

## Sign-in flow (D2 detail)

```
User taps "Sign in with Google" (paywall checkout OR Settings)
  │
  ▼
AuthRepository.signInWithGoogle() runs:
  │
  1. Trigger google_sign_in native sheet
     ├─ user cancels  → return SignInResult.cancelled
     └─ user picks    → GoogleSignInAuthentication tokens
  │
  2. Build GoogleAuthProvider.credential(idToken:, accessToken:)
  │
  3. try { FirebaseAuth.instance.currentUser!.linkWithCredential(cred) }
     │
     ├─ SUCCESS (no prior Firebase user for this Google uid):
     │    │
     │    ▼
     │    Create /users/{uid} doc (rules allow create with createdAt = request.time)
     │      → triggers onUserCreated Function → writes audit log: event=accountCreated
     │    Call recordSignInEvent() callable Function → writes audit log: event=signInLinked
     │    Call SyncCoordinator.pushLocalToCloud()
     │    Return SignInResult.linkedExisting
     │
     └─ FAILURE "credential-already-in-use":
          │
          ▼
          4. Save: oldAnonUid = currentUser.uid
                   localHasData = LocalStateWiper.hasMeaningfulProgress()
          5. FirebaseAuth.instance.signOut()
          6. FirebaseAuth.instance.signInWithCredential(cred)  → newCurrentUser
          7. cloudHasData = await /users/{newCurrentUser.uid} exists with meaningful fields
          8. Call recordSignInEvent() callable Function → writes audit log: event=signInLinked
          9. Return SignInResult.switchedToExisting(cloudHasData, localHasData)
              // UI branches:
              // (cloud=true, local=true)  → push to MergePromptPage
              // (cloud=true, local=false) → SyncCoordinator.pullCloudToLocal() silently
              // (cloud=false, local=true) → SyncCoordinator.pushLocalToCloud() silently
              // (cloud=false, local=false)→ no-op (clean slate)
          10. Orphaned oldAnonUid stays in Firebase Auth until purged by
              scheduled function `cleanupOrphanAnons` (daily, deletes anon uids
              with no Firestore doc and lastSignIn > 30 days).
```

**"Meaningful progress" predicate** lives on `LocalStateWiper` (interface in this spec; impl in Spec 3):
```dart
Future<bool> hasMeaningfulProgress();
// Implementation: SELECT 1 FROM lessons_read LIMIT 1
//                 OR  SELECT 1 FROM quiz_attempts LIMIT 1
//                 OR  SELECT 1 FROM fsrs_cards LIMIT 1
```
For cloud-side `meaningfulCloudData`, the same predicate is computed from `/users/{uid}/lesson_progress`, `/users/{uid}/quiz_attempts`, `/users/{uid}/fsrs_cards` subcollections via `count()` aggregation queries (cheap, single round trip).

### MergePromptPage UX

```
Welcome back. We found progress on your account.

  This device (anonymous):
    14 lessons read · 230 reviews due · 3 quizzes

  Your account (last synced 4 months ago):
    6 lessons read · 0 reviews due · 1 quiz

  Which would you like to keep? (The other will be discarded.)

  [ Keep this device ]   [ Keep my account ]
```

Picking "this device" calls `SyncCoordinator.pushLocalToCloud()` (overwrites cloud). Picking "my account" calls `SyncCoordinator.pullCloudToLocal()` (wipes local then pulls). Page is non-dismissable (no back button, no system back) — choice is required to proceed past sign-in.

### Re-auth gate

Firebase requires fresh auth (≤5 min) for sensitive operations. `AuthRepository.deleteAccount()`:
1. Read `currentUser.metadata.lastSignInTime`.
2. If older than 5 min, call `currentUser.reauthenticateWithCredential(googleCredential)` (triggers fresh Google sign-in sheet).
3. Then call the `deleteAccount` Cloud Function.

### Failure handling

| Failure point | Behavior |
|---|---|
| Network drop during native sign-in | User sees Google's native error; app state unchanged. |
| `linkWithCredential` succeeds, push to cloud fails | Not a sign-in failure; SyncCoordinator queues for retry. UI shows generic sync indicator. |
| Collision flow fails between signOut and signInWithCredential | `ensureAnonymous()` creates a *new* anon uid. Local data still on device. On next successful sign-in, treated as anon→named with local data. Orphan anon reaped by cleanup function. |
| Any other `FirebaseAuthException` | Return `SignInResult.failed(reason: e.code)`. UI shows generic error toast. Crashlytics logs with redacted email. |

---

## Sign-out flow (D7 detail)

```
User taps "Sign out" in Settings
  │
  ▼
Show confirmation dialog:
  "Sign out will remove your progress from this device.
   Your data stays safe in your account and will sync back when you sign in."
  [ Cancel ]  [ Sign out ]
  │
  ▼ (Sign out tapped)
Show modal "Signing out…" spinner
  │
  ▼
1. LocalStateWiper.wipeAll()
     - Drops + recreates Drift tables: lessons_read, quiz_attempts, fsrs_cards,
       assessments, study_plan, mock_exam_attempts.
     - Preserves: app_preferences (theme, locale).
     - Invalidates Riverpod state for affected feature providers.
2. await FirebaseAuth.instance.signOut()
3. await GoogleSignIn.instance.signOut()
4. await ensureAnonymous()
     - FirebaseAuth.signInAnonymously() creates fresh anon uid.
     - authStateProvider emits anonymous(newAnonUid).
5. Router redirect: if current location requires sign-in → pop to /home.
6. Dismiss spinner.
7. Show one-time snackbar: "Signed out. You can sign back in any time from Settings."
```

**Edge cases:**
- **Killed between step 1 and step 2:** App relaunches with wiped Drift but still-named Firebase user. `main.dart` boot guard: if Drift is empty AND Firebase user is named, immediately invoke `signOut()` again (idempotent).
- **Step 4 fails (offline):** Show "Working offline" banner. `currentUserProvider` returns null. App still functions on Drift. `ensureAnonymous()` retries on next online launch.

---

## Account deletion + data export (D3 detail)

### Settings UI

Privacy section, gated by `isSignedInProvider`:
- "Export my data" row → calls `exportData` → opens signed URL in system browser.
- "Delete my account" row → bottom sheet:
  > "This will permanently delete all your data. This cannot be undone. Type DELETE to confirm."
  - Text field; "Delete" button enabled only when text equals `DELETE`.
  - On confirm → re-auth Google sign-in → call `deleteAccount` Function → navigate to terminal screen "Your account has been deleted" with single button "Close app".

For anonymous users, both rows show a disabled state with subtitle: "Sign in first to export or delete your account data."

### Cloud Functions (`functions/` directory, Node 20, deployed to prod)

**Module structure:**
```
functions/
├── package.json
├── src/
│   ├── index.ts                // exports all callables + triggers + scheduled jobs
│   ├── exportData.ts           // callable
│   ├── deleteAccount.ts        // callable
│   ├── recordSignInEvent.ts    // callable; writes signInLinked audit entry
│   ├── onUserCreated.ts        // Firestore trigger; writes accountCreated audit entry
│   ├── cleanupOrphanAnons.ts   // scheduled
│   ├── purgeOldExports.ts      // scheduled
│   ├── purgeOldAuditLogs.ts    // scheduled
│   └── _audit.ts               // writeAuditLog helper
└── test/
    ├── rules.test.ts
    ├── exportData.test.ts
    ├── deleteAccount.test.ts
    ├── recordSignInEvent.test.ts
    └── onUserCreated.test.ts
```

**`exportData` (callable):**
```
options: { region: 'asia-southeast1', enforceAppCheck: true,
           consumeAppCheckToken: true }
flow:
  1. Verify request.auth.uid present; reject if provider == 'anonymous'.
  2. Read /users/{uid} and all owned subcollections:
       /users/{uid}/lesson_progress
       /users/{uid}/quiz_attempts
       /users/{uid}/fsrs_cards
       /users/{uid}/assessments
       /users/{uid}/study_plan
       /users/{uid}/mock_exam_attempts
  3. Assemble JSON { schemaVersion: 1, exportedAt, uid, ...collections }.
  4. Upload to gs://<prod-bucket>/exports/{uid}/{ISO timestamp}.json (private).
  5. Generate signed URL, expires 24h.
  6. writeAuditLog({ event: 'dataExported', uid, metadata: { byteSize } }).
  7. Return { downloadUrl, expiresAt }.
```

**`deleteAccount` (callable):**
```
options: { region: 'asia-southeast1', enforceAppCheck: true,
           consumeAppCheckToken: true }
flow:
  1. Verify request.auth.uid present; reject if provider == 'anonymous'.
  2. Verify request.auth.token.auth_time within last 5 minutes (server-side re-auth gate).
  3. writeAuditLog({ event: 'accountDeleted', uid }).  // BEFORE deletion
  4. firestore.recursiveDelete('/users/{uid}').
  5. Delete /exports/{uid}/* from Cloud Storage.
  6. DELETE https://api.revenuecat.com/v1/subscribers/{uid}
       headers: Authorization Bearer <REVENUECAT_SECRET_KEY from Secret Manager>
       (irreversible — Pro entitlement gone; user warned in confirmation copy).
  7. admin.auth().deleteUser(uid).
  8. Return { deletedAt }.
  → Client wipes Drift, navigates to terminal screen.
```

**`recordSignInEvent` (callable):**
```
options: { region: 'asia-southeast1', enforceAppCheck: true }
flow:
  1. Verify request.auth.uid present; reject if provider == 'anonymous'.
  2. writeAuditLog({ event: 'signInLinked', uid }).
  3. Return { logged: true }.
```

**`onUserCreated` (Firestore trigger on `/users/{uid}` `onCreate`, region asia-southeast1):**
```
flow:
  1. writeAuditLog({ event: 'accountCreated', uid: context.params.uid }).
```
Exactly-once per uid by construction (Firestore `onCreate` fires once per document).

**`cleanupOrphanAnons` (scheduled, daily 03:00 SGT):**
List anonymous Auth users with `lastSignInTime` > 30 days ago and no Firestore doc; `admin.auth().deleteUser` each. Batch of 100/run.

**`purgeOldExports` (scheduled, daily 03:15 SGT):**
Delete `/exports/**` blobs with `created` > 7 days ago.

**`purgeOldAuditLogs` (scheduled, daily 03:30 SGT):**
Delete `/audit_logs/*` docs with `timestamp` > 730 days ago. Batch of 100/run.

### Secrets

Stored in Google Secret Manager (project: prod):
- `REVENUECAT_SECRET_KEY`

Granted via `firebase functions:secrets:set REVENUECAT_SECRET_KEY` and accessed via `defineSecret` in the relevant function definition.

---

## Audit logging (D8 detail)

**All audit log writes happen server-side.** The client never writes to `/audit_logs/*` (rules deny it). Events reach the audit log via:
- **Firestore trigger `onUserCreated`** — observes `/users/{uid}` `onCreate` → writes `accountCreated`.
- **Callable `recordSignInEvent`** — invoked by client after every successful sign-in (link or fallback) → writes `signInLinked`. Enforces App Check + non-anonymous caller.
- **`dataExported` and `accountDeleted`** are written inline by their own Functions.

**Layer 1 — Cloud Logging** (free, automatic). Every Function call writes:
```
functions.logger.info('audit', {
  event: 'accountDeleted' | 'dataExported' | 'signInLinked' | 'accountCreated',
  uid,
  requestId: context.eventId,
  ipHash: sha256(context.rawRequest.ip),
  appVersion: context.rawRequest.headers['x-app-version'],
});
```
Audit log bucket retention extended to 400 days via `gcloud logging buckets update`.

**Layer 2 — Firestore `audit_logs`** (durable, server-only):
```
/audit_logs/{autoId} = {
  uid: string,
  event: 'accountCreated' | 'signInLinked' | 'dataExported' | 'accountDeleted',
  timestamp: serverTimestamp,
  metadata: {
    ipHash: string,
    appVersion: string,
    byteSize?: number,    // for dataExported
  }
}
```
Security rules: `allow read, write: if false;` (admin SDK only).

Anonymous-only users produce zero audit log entries (anon never creates a `/users/{uid}` doc and never invokes `recordSignInEvent`). `accountCreated` is naturally idempotent — `/users/{uid}` `onCreate` fires exactly once per uid.

---

## App Check (D5 detail)

| | Dev project | Prod project |
|---|---|---|
| Provider | Debug | Play Integrity |
| Activation | `FirebaseAppCheck.instance.activate(androidProvider: AndroidProvider.debug)` | `FirebaseAppCheck.instance.activate(androidProvider: AndroidProvider.playIntegrity)` |
| Firestore enforcement | On | On |
| Storage enforcement | On | On |
| Callable Function enforcement | Per-function `enforceAppCheck: true` | Per-function `enforceAppCheck: true` |
| Replay protection | `consumeAppCheckToken: true` on `deleteAccount`, `exportData` only | Same |
| Token TTL | SDK default (~1h), auto-refresh on | Same |

**Dev workstation onboarding** (documented in `CONTRIBUTING.md`):
1. Build + run dev flavor: `flutter run --dart-define=APP_ENV=dev --flavor dev`
2. App logs the generated debug token to console on first run.
3. Firebase console → Project `cse-cet-reviewer-dev` → App Check → Apps → Android app → Manage debug tokens → Add token → paste.
4. CI device follows the same flow with a CI-named token.

**Failure modes:**
- Rooted device / sideloaded build → Play Integrity returns low verdict → backend rejects → app shows generic "Couldn't connect — please try again from a Play Store installation" banner. No mention of integrity (defense in depth).
- Offline at launch → token not fetched; Firestore queries are local-only via Drift. On reconnect, token fetches; SyncCoordinator resumes.

---

## Firestore security rules (D entire backend gate)

File: `firestore.rules` (committed at repo root; deployed via `firebase deploy --only firestore:rules --project {dev|prod}`).

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isSignedIn()   { return request.auth != null; }
    function isNamedUser()  {
      return isSignedIn()
          && request.auth.token.firebase.sign_in_provider != 'anonymous';
    }
    function isOwner(uid)   { return isNamedUser() && request.auth.uid == uid; }

    match /users/{uid} {
      allow read:   if isOwner(uid);
      allow create: if isOwner(uid)
                      && request.resource.data.keys().hasAll(['createdAt'])
                      && request.resource.data.createdAt == request.time;
      allow update: if isOwner(uid)
                      && request.resource.data.diff(resource.data)
                              .affectedKeys()
                              .hasOnly(['displayName','photoUrl','lastSeenAt',
                                        'preferences','schemaVersion']);
      allow delete: if false;  // deleteAccount Function only

      match /lesson_progress/{lessonId}  { allow read, write: if isOwner(uid); }
      match /quiz_attempts/{attemptId}   { allow read, write: if isOwner(uid); }
      match /fsrs_cards/{cardId}         { allow read, write: if isOwner(uid); }
      match /assessments/{assessmentId}  { allow read, write: if isOwner(uid); }
      match /study_plan/{docId}          { allow read, write: if isOwner(uid); }
      match /mock_exam_attempts/{aId}    { allow read, write: if isOwner(uid); }
    }

    match /audit_logs/{logId} { allow read, write: if false; }

    match /{document=**}      { allow read, write: if false; }
  }
}
```

**Invariants enforced:**
1. Anonymous users have zero Firestore access (read or write).
2. A named user can only touch `/users/{theirUid}/**`.
3. `/users/{uid}` root doc updates restricted to a small allowlist — prevents client-injected fields (e.g., a fabricated `isPro: true`).
4. `/users/{uid}` deletes denied at the rule layer; only admin SDK in `deleteAccount` can delete.
5. **Pro entitlement is NOT in Firestore.** RevenueCat is the source of truth. No `isPro` field anywhere. Eliminates the "flip my own flag" attack class.
6. `audit_logs` is server-only.
7. Unknown paths default-deny.

**Content collections** (Sanity-sourced lessons, questions, mocks) are NOT in Firestore — they live in Drift via Spec 2. Firestore rules surface stays minimal.

---

## Testing strategy

### Layer 1 — Flutter unit tests (`test/core/auth/`)
Pure Dart, mocked dependencies (mocktail).
- `AuthRepository` happy paths: `ensureAnonymous`, `signInWithGoogle` returns each `SignInResult` variant.
- State transitions: `AuthState` unknown → anonymous → signedIn → signedOut → anonymous.
- Riverpod providers: `currentUserProvider`, `isSignedInProvider`, `isAnonymousProvider` derivations.
- B3-lite decision table: each `(cloudHasData, localHasData)` combination → expected SyncCoordinator call (or prompt).
- Sign-out order: `LocalStateWiper.wipeAll` is called BEFORE `FirebaseAuth.signOut`.
- `recordSignInEvent` callable is invoked after every successful sign-in (link path and collision-fallback path).

**Coverage target:** >90% lines on `lib/core/auth/`.

### Layer 2 — Integration tests against Firebase Emulator Suite (`integration_test/auth/`)
Run via `firebase emulators:exec --only auth,firestore,functions "flutter test integration_test/"`. Real Firebase SDKs against local emulators.

- **anon-to-google-link-clean.dart** — anon uid → link with fresh Google credential → assert uid preserved, Firestore doc created with `accountCreated` audit entry.
- **anon-to-google-collision.dart** — pre-seed `/users/uidA` with data → attempt link from anon uidB with same Google credential → expect `credential-already-in-use` → fallback path runs → anon uidB orphaned → signed in as uidA → `signInLinked` audit entry written.
- **sign-out-wipes-drift.dart** — sign in, populate Drift fake data, sign out, assert user-data tables empty, `app_preferences` intact.
- **delete-account-reauth.dart** — fast-forward emulator clock past 5min → attempt delete → expect re-auth prompt path → after re-auth, function returns success, Firestore doc gone, Auth user gone, `accountDeleted` audit entry written, RevenueCat mock received DELETE call.
- **export-data-roundtrip.dart** — call `exportData` → fetch signed URL → assert JSON shape matches schema → `dataExported` audit entry written.

### Layer 3 — Security rules tests (`functions/test/rules.test.ts`)
`@firebase/rules-unit-testing` against the Firestore emulator.
- anon user CANNOT read `/users/anyUid` (denied).
- named user CAN read `/users/{ownUid}` but CANNOT read `/users/{otherUid}`.
- named user CANNOT write `isPro` or any unlisted root-doc field.
- no client (anon or named) can read `/audit_logs/*`.
- default deny on `/random_collection/*`.

### Layer 4 — Cloud Function tests (`functions/test/`)
Firebase Functions Test SDK. Run in CI alongside rules tests.
- `exportData`: rejects anonymous caller, rejects missing App Check, returns signed URL on happy path, writes `dataExported` audit log.
- `deleteAccount`: rejects stale auth_time, calls RevenueCat DELETE, calls recursiveDelete, writes `accountDeleted` audit log BEFORE deletion.
- `recordSignInEvent`: rejects anonymous caller, rejects missing App Check, writes `signInLinked` audit log on happy path.
- `onUserCreated`: writes `accountCreated` audit log exactly once on `/users/{uid}` create.

### CI wiring (`.github/workflows/ci.yml`)

Three parallel jobs:
- `flutter-unit` — `flutter test`
- `flutter-integration` — emulator suite + `flutter test integration_test/`
- `backend` — emulator suite + `cd functions && npm test`

All three must pass for PR merge to main.

**Cloud Functions deploy is manual** during soft-launch phase:
```
firebase deploy --only functions --project prod
```
No auto-deploy from main. Adds friction but avoids accidental destructive Function rollouts during a high-stakes launch window.

### Manual pre-launch verification (checklist)

Cannot fully automate; run on a real device before each prod build:
- [ ] Real Google sign-in completes on a debug build pointed at dev project.
- [ ] App Check debug token registered for the test device.
- [ ] Account deletion on a throwaway real account → confirm: Firebase Auth user gone, Firestore docs gone, RevenueCat subscriber deleted (check dashboard), `accountDeleted` audit log present in Firestore.
- [ ] Data export from a real account → confirm signed URL downloads complete JSON with all expected collections.
- [ ] Play Integrity verdict succeeds on a Play Store internal-track install (build uploaded via Play Console, installed via internal testing link).

---

## Deliverables

**Repo additions:**
- `lib/core/auth/auth.dart`, `auth_repository.dart`, `auth_state.dart`, `sign_in_result.dart`, `local_state_wiper.dart` (interface), `sync_coordinator.dart` (interface), `providers.dart`.
- `lib/firebase_options_dev.dart`, `lib/firebase_options_prod.dart` (generated, committed).
- `android/app/src/dev/google-services.json`, `android/app/src/prod/google-services.json`.
- `android/app/build.gradle.kts` updated with `dev` + `prod` product flavors.
- `firestore.rules` at repo root.
- `firebase.json` at repo root (emulator + deploy config).
- `functions/` directory with `package.json`, TypeScript source, tests.
- `test/core/auth/` unit tests.
- `integration_test/auth/` integration tests.
- `.github/workflows/ci.yml` updated with new jobs.
- `CONTRIBUTING.md` section on debug-token registration.

**Firebase console (manual) — dev project:**
- Project created.
- Anonymous + Google sign-in providers enabled.
- Firestore database created in `asia-southeast1`.
- App Check configured with debug provider.
- Firestore + Storage App Check enforcement toggled ON.

**Firebase console (manual) — prod project:**
- Project created, upgraded to Blaze plan (billing card attached).
- Anonymous + Google sign-in providers enabled.
- Firestore database created in `asia-southeast1`.
- App Check configured with Play Integrity (after first AAB uploaded to Play Console).
- Firestore + Storage App Check enforcement toggled ON.
- Secret `REVENUECAT_SECRET_KEY` set via `firebase functions:secrets:set`.
- Audit log bucket retention extended to 400 days via `gcloud logging buckets update`.

**Sign-off:**
- All four CI jobs green on the spec's implementation PR.
- Manual pre-launch verification checklist completed.

---

## Next step

After this design is approved, invoke the `superpowers:writing-plans` skill to produce the implementation plan at `docs/superpowers/plans/2026-05-16-firebase-auth.md`. The plan will break the deliverables above into ordered, testable work units suitable for `superpowers:executing-plans`.
