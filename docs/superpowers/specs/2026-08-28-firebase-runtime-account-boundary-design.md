# Firebase Runtime Account-Boundary Design

## Status

Approved coordinator design for Firebase Runtime Wave 2C.

Base integration SHA: `0cfb08f6a7e83063af46f020de543af7dcf99ad5`.

This design exists to make later Auth and Sync wiring safe at identity changes. It does not activate Firebase Auth or cloud Sync.

## Product boundary

The current account model is:

- anonymous Free user: local only;
- named Free user: local only;
- named Pro user: eligible for cloud backup/sync.

Google sign-in establishes identity. It does not by itself activate backup for a Free user.

When a local-only user first becomes sync-eligible, later Sync work will use the existing B3-lite four-way decision: no meaningful data on either side -> no-op; local only -> full push; cloud only -> full pull; both -> explicit Keep this device / Keep my account choice. Record-level merge remains out of scope.

If Pro expires, Sync must stop without deleting local or cloud state. If Pro later returns, reconciliation must run again before Sync resumes.

## Ownership boundary

Auth owns identity, credentials, named-account lifecycle, and account transition requests.

Sync owns cloud/local meaningful-data checks, backup/restore, pending work, listeners, and the concrete transition behavior once live Sync exists.

Wave 2C freezes the shared seam between them. Wave 2C does not construct Firebase Auth, FirebaseFirestore, FirebaseFunctions, or a production Sync engine.

## Account-transition seam

Add an Auth-owned interface named `AccountTransitionGateway` with three explicit operations:

```dart
abstract interface class AccountTransitionGateway {
  Future<void> prepareForSignOut();
  Future<void> prepareForAccountSwitch();
  Future<void> prepareForDeleteAccount();
}
```

Provide a `NoopAccountTransitionGateway` default so current unwired runtime behavior does not change merely because the seam exists.

`AuthRepository` must invoke the seam before destructive or identity-changing work:

- normal sign-out: `prepareForSignOut()` before local wipe;
- credential collision/account switch: `prepareForAccountSwitch()` before Firebase sign-out / UID replacement;
- account deletion: after any required recent-login step succeeds, call `prepareForDeleteAccount()` before the server deletion callable and before local wipe.

If preparation throws, the identity-changing/destructive operation must not proceed. Later Sync runtime work may implement sign-out preparation as a final flush + quiesce and deletion preparation as quiesce-without-flush.

Wave 2C does not implement those future Sync behaviors.

## Local account-state wipe

`SyncLocalStateWiper.wipeAll()` must remove durable state whose meaning belongs to the current student/account.

It must delete at least:

- `attemptsLocal`
- `assessmentResultsLocal`
- `reviewStateLocal`
- `streakLocal`
- `lessonProgressLocal`
- `lessonBookmarksLocal`
- `questionFlagsLocal`
- `accountPrefs`
- `pendingSync`
- `quizSessions`
- `dailyNewCardIntro`
- `mockAttempts`
- `userMetricsArchetypesLocal`
- `userMetricsArtifactsLocal`
- `reviewLogs`
- `trackScopeLocal`
- `customBlueprintsLocal`

The wipe remains transactional after notification cancellation.

It must preserve installation/reference/device state, including:

- seeded/reference content tables (`exams`, `subjects`, `topics`, `questions`, `lessons`, `passages`);
- `devicePrefs`;
- legacy `appPreferencesLocal` because it still stores/falls back to device-level onboarding/age/exam state;
- `quizNudgeDismissedLocal` as a device presentation/nudge state;
- the `syncMeta` row with key `deviceId`.

All other current `syncMeta` rows are account/runtime sync state and are removed.

No database schema change is required for Wave 2C.

## Meaningful local progress

`hasMeaningfulProgress()` exists to prevent silent loss when an account boundary must decide which side wins. It must detect substantive student-authored or durable academic state, not merely device preferences or derived caches.

Treat these as meaningful for Wave 2C:

- quiz attempts;
- assessment results;
- FSRS/review state;
- streak state;
- lesson progress;
- lesson bookmarks;
- question flags;
- mock attempts;
- review logs/history;
- custom track scope;
- custom blueprint data.

Do not make preferences, pending queue rows, metrics caches, daily intro counters, quiz-session scaffolding, or nudge/device state sufficient on their own to return true.

The implementation should use cheap existence checks and return as soon as one meaningful table contains a row.

## Cloud meaningful-progress query

`SyncCloudProgressGateway` must stop inferring anonymous status from UID text. Firebase anonymous UIDs are opaque.

Remove the `uid.startsWith('anon-')` check. The gateway receives a UID that its caller has already determined is allowed for a cloud query. Later Auth/Sync lifecycle code will use explicit `AuthSession.isAnonymous` and entitlement state to decide whether the gateway may be called.

For the current B3 meaning check, cloud collections that count as meaningful are:

- `quiz_attempts`
- `assessments`
- `fsrs_cards`
- `lesson_progress`
- `lesson_bookmarks`
- `question_flags`
- `mock_exam_attempts`

Preferences alone do not make a cloud side meaningful.

## Sign-out and deletion safety

Wave 2C only establishes ordering and local data ownership.

It does not fix Firebase reauthentication, backend account deletion, Google Sign-In, Auth provider wiring, or live Sync lifecycle. Those belong to later waves.

The transition seam must nevertheless guarantee that a future Sync implementation can stop/flush before `AuthRepository` wipes data or changes UID.

## Non-goals

Wave 2C must not:

- implement Firebase Auth adapters;
- initialize Google Sign-In;
- call Firebase Functions;
- activate anonymous Auth startup;
- create `/users/{uid}`;
- implement Firestore adapters;
- implement push/pull/listeners;
- modify Firestore rules or Functions;
- implement Pro gating;
- implement B3 UI;
- modify RevenueCat;
- activate telemetry user identity;
- change database schema;
- run or deploy Firebase services.

## Verification

Focused tests must prove:

- transition preparation runs before sign-out wipe and UID replacement;
- a preparation failure stops sign-out/account switch/delete before destructive work;
- wipe removes every account-owned table listed above;
- wipe preserves device/reference state and only `syncMeta.deviceId`;
- meaningful progress catches newer data families, including mock/history/custom-track cases;
- preferences/device-only state is not meaningful by itself;
- cloud meaningful progress checks all current substantive cloud collections;
- UID strings are never interpreted as an anonymous security boundary.
