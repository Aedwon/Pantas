# Firebase Runtime Account Boundary Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make account identity transitions safe by freezing a Sync preparation seam, completing local account-state cleanup/meaningful-progress detection, and removing UID-string heuristics from cloud progress checks.

**Architecture:** Auth owns the transition interface because Auth initiates sign-out, account switching, and deletion. Sync supplies the eventual runtime implementation, while Wave 2C ships only a no-op default so no live Sync behavior is activated. `SyncLocalStateWiper` remains the single local account-state cleanup implementation, and `SyncCloudProgressGateway` remains a pure query over an injected Firestore abstraction.

**Tech Stack:** Flutter/Dart, Riverpod-independent domain interfaces, Drift, existing Auth/Sync abstractions and Flutter tests.

**Spec:** `docs/superpowers/specs/2026-08-28-firebase-runtime-account-boundary-design.md`

## Global Constraints

- Base implementation line is the Wave 1 integration plus this coordinator documentation commit chain.
- Do not implement Firebase Auth, Google Sign-In, Firebase Functions clients, Firestore clients, Sync listeners, Pro gating, or B3 UI.
- Do not change the Drift schema or run `build_runner` as part of implementation.
- Preserve `devicePrefs`, legacy `appPreferencesLocal`, `quizNudgeDismissedLocal`, seeded/reference content, and `syncMeta.deviceId` during account wipe.
- No Actions or remote Firebase/Play/Sanity mutations.

---

### Task 1: Freeze the Auth-to-Sync transition seam

**Files:**
- Create: `lib/core/auth/account_transition_gateway.dart`
- Modify: `lib/core/auth/auth.dart`
- Modify: `lib/core/auth/auth_repository.dart`
- Test: `test/core/auth/auth_repository_sign_out_test.dart`
- Test: `test/core/auth/auth_repository_collision_test.dart`
- Test: `test/core/auth/auth_repository_privacy_test.dart`

**Interfaces:**
- Produces: `AccountTransitionGateway` with `prepareForSignOut()`, `prepareForAccountSwitch()`, and `prepareForDeleteAccount()`.
- Produces: `NoopAccountTransitionGateway` as the default dependency in `AuthRepository`.
- Later Sync runtime will implement the interface; Wave 2C does not.

- [ ] **Step 1: Write failing ordering tests**

Extend the existing operation-log tests so sign-out expects preparation before wipe:

```dart
expect(operations, [
  'prepareForSignOut',
  'wipeAll',
  'firebaseSignOut',
  'googleSignOut',
  'signInAnonymously',
]);
```

Extend collision coverage so the credential-already-in-use fallback expects preparation before the old Firebase UID is signed out:

```dart
expect(gateway.operations, [
  'link',
  'prepareForAccountSwitch',
  'signOut',
  'signInWithCredential',
]);
```

Extend fresh-login deletion coverage so preparation occurs before the callable:

```dart
expect(operations, [
  'prepareForDeleteAccount',
  'deleteAccount',
  'wipeAll',
  'signOut',
  'googleSignOut',
  'signInAnonymously',
]);
```

- [ ] **Step 2: Write failing abort tests**

Add a recording/failing transition fake. Prove that each preparation failure prevents the next destructive operation:

```dart
await expectLater(repo.signOut(), throwsA(isA<StateError>()));
expect(operations, ['prepareForSignOut']);
```

For account switch, prove no Firebase sign-out happens after `prepareForAccountSwitch()` throws. For deletion, prove no delete callable, local wipe, or sign-out happens after `prepareForDeleteAccount()` throws.

- [ ] **Step 3: Run the focused Auth tests and confirm failure**

Run:

```bash
flutter test --no-test-assets \
  test/core/auth/auth_repository_sign_out_test.dart \
  test/core/auth/auth_repository_collision_test.dart \
  test/core/auth/auth_repository_privacy_test.dart
```

Expected: FAIL because the transition interface/invocations do not exist yet.

- [ ] **Step 4: Add the transition interface and no-op implementation**

Create:

```dart
abstract interface class AccountTransitionGateway {
  Future<void> prepareForSignOut();
  Future<void> prepareForAccountSwitch();
  Future<void> prepareForDeleteAccount();
}

class NoopAccountTransitionGateway implements AccountTransitionGateway {
  const NoopAccountTransitionGateway();

  @override
  Future<void> prepareForSignOut() async {}

  @override
  Future<void> prepareForAccountSwitch() async {}

  @override
  Future<void> prepareForDeleteAccount() async {}
}
```

Export it from `auth.dart`.

- [ ] **Step 5: Inject and invoke it in AuthRepository**

Add an optional constructor dependency defaulting to `const NoopAccountTransitionGateway()`.

Required ordering:

```dart
Future<void> signOut() async {
  await _accountTransitionGateway.prepareForSignOut();
  await _localStateWiper.wipeAll();
  await _gateway.signOut();
  await _googleGateway.signOut();
  await ensureAnonymous();
}
```

In `_switchToExistingGoogleAccount`, call `prepareForAccountSwitch()` after the local meaningful-data check and before `_gateway.signOut()`.

In `deleteAccount`, keep the current recent-login flow unchanged in this wave, then call `prepareForDeleteAccount()` immediately before `_functionsGateway.deleteAccount()`.

Do not catch preparation failures inside `AuthRepository`; propagation is what prevents the transition from continuing.

- [ ] **Step 6: Run the focused Auth tests**

Run the three-file command from Step 3.

Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add \
  lib/core/auth/account_transition_gateway.dart \
  lib/core/auth/auth.dart \
  lib/core/auth/auth_repository.dart \
  test/core/auth/auth_repository_sign_out_test.dart \
  test/core/auth/auth_repository_collision_test.dart \
  test/core/auth/auth_repository_privacy_test.dart

git commit -m "feat(auth): add account transition boundary"
```

---

### Task 2: Complete local account-state wipe and meaningful-progress detection

**Files:**
- Modify: `lib/core/sync/local_state_wiper.dart`
- Test: `test/core/sync/local_state_wiper_test.dart`
- Test: `test/core/sync/meaningful_progress_test.dart`

**Interfaces:**
- Keeps the existing `LocalStateWiper` interface unchanged.
- Produces a complete account-scoped wipe and a conservative academic-data existence check for later B3 reconciliation.

- [ ] **Step 1: Extend wipe tests with all account-owned tables**

Seed and then assert empty after `wipeAll()` for:

```text
attemptsLocal
assessmentResultsLocal
reviewStateLocal
streakLocal
lessonProgressLocal
lessonBookmarksLocal
questionFlagsLocal
accountPrefs
pendingSync
quizSessions
dailyNewCardIntro
mockAttempts
userMetricsArchetypesLocal
userMetricsArtifactsLocal
reviewLogs
trackScopeLocal
customBlueprintsLocal
```

Keep notification cancellation asserted before the transaction starts.

- [ ] **Step 2: Replace the stale preservation test**

The old test incorrectly preserves `streakLocal`. Replace it with a preservation test that seeds and retains:

```text
devicePrefs
appPreferencesLocal
quizNudgeDismissedLocal
syncMeta(deviceId)
seed/reference content rows needed by foreign keys
```

Also seed another `syncMeta` key such as `failedSince` and assert only `deviceId` survives.

- [ ] **Step 3: Extend meaningful-progress tests**

Keep device/preferences-only state false. Add representative true cases for the newer families so at minimum these cases are locked:

```text
assessment-only
streak-only
bookmark-only
question-flag-only
mock-attempt-only
review-log-only
track-scope-only
custom-blueprint-only
```

Metrics caches, `accountPrefs`, `pendingSync`, `dailyNewCardIntro`, `quizSessions`, and nudge/device state must not return true by themselves.

- [ ] **Step 4: Run the focused Sync tests and confirm failure**

```bash
flutter test --no-test-assets \
  test/core/sync/local_state_wiper_test.dart \
  test/core/sync/meaningful_progress_test.dart
```

Expected: FAIL on the currently preserved/missed tables and stale meaningful-progress inventory.

- [ ] **Step 5: Update `wipeAll()`**

Inside the existing Drift transaction, delete every account-owned table listed in Step 1. Preserve `devicePrefs`, `appPreferencesLocal`, `quizNudgeDismissedLocal`, seeded/reference tables, and `syncMeta.deviceId`.

Keep the existing pattern that snapshots `deviceId`, clears `syncMeta`, then reinserts that row.

Do not change the schema.

- [ ] **Step 6: Update `hasMeaningfulProgress()`**

Use one-row existence queries and early returns. The meaningful set is:

```text
attemptsLocal
assessmentResultsLocal
reviewStateLocal
streakLocal
lessonProgressLocal
lessonBookmarksLocal
questionFlagsLocal
mockAttempts
reviewLogs
trackScopeLocal
customBlueprintsLocal
```

Do not count account/device preferences, metrics caches, pending queue rows, nudge state, daily intro counters, or quiz session scaffolding alone.

- [ ] **Step 7: Run the two focused Sync tests**

Run the Step 4 command.

Expected: PASS.

- [ ] **Step 8: Commit**

```bash
git add \
  lib/core/sync/local_state_wiper.dart \
  test/core/sync/local_state_wiper_test.dart \
  test/core/sync/meaningful_progress_test.dart

git commit -m "fix(sync): complete local account state boundary"
```

---

### Task 3: Remove UID-pattern auth inference and expand cloud meaningful-data coverage

**Files:**
- Modify: `lib/core/sync/cloud_progress_gateway.dart`
- Test: `test/core/sync/cloud_progress_gateway_test.dart`

**Interfaces:**
- Keeps `CloudProgressGateway.hasMeaningfulProgress(String uid)` unchanged for now.
- Caller owns anonymous/entitlement eligibility; this gateway only queries the supplied named-user UID.

- [ ] **Step 1: Replace the anonymous-prefix test**

Delete the test asserting that `anon-1` is rejected.

Add a test proving UID text is opaque. For example, seed:

```dart
gateway.collections['users/anon-looking-but-named/quiz_attempts'] = [
  {'id': 'a1'},
];
```

and assert `hasMeaningfulProgress('anon-looking-but-named')` returns true. The test must establish that the gateway does not interpret UID prefixes.

- [ ] **Step 2: Add current collection coverage tests**

In addition to existing quiz/lesson/FSRS tests, add positive coverage for:

```text
assessments
lesson_bookmarks
question_flags
mock_exam_attempts
```

Keep preferences/root-document data out of the meaningful list.

- [ ] **Step 3: Run the gateway test and confirm failure**

```bash
flutter test --no-test-assets test/core/sync/cloud_progress_gateway_test.dart
```

Expected: FAIL because the prefix rejection and incomplete collection list still exist.

- [ ] **Step 4: Update the gateway**

Remove:

```dart
if (uid.startsWith('anon-')) {
  throw ArgumentError.value(uid, 'uid', 'anonymous users do not sync');
}
```

Set `_meaningfulCollections` to exactly:

```dart
static const _meaningfulCollections = [
  'quiz_attempts',
  'assessments',
  'fsrs_cards',
  'lesson_progress',
  'lesson_bookmarks',
  'question_flags',
  'mock_exam_attempts',
];
```

- [ ] **Step 5: Run the gateway test**

Run the Step 3 command.

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add \
  lib/core/sync/cloud_progress_gateway.dart \
  test/core/sync/cloud_progress_gateway_test.dart

git commit -m "fix(sync): make cloud progress identity explicit"
```

---

### Task 4: Final focused verification

**Files:** No production changes expected.

**Interfaces:** Verifies the Wave 2C contract only.

- [ ] **Step 1: Run all Wave 2C focused tests together**

```bash
flutter test --no-test-assets \
  test/core/auth/auth_repository_sign_out_test.dart \
  test/core/auth/auth_repository_collision_test.dart \
  test/core/auth/auth_repository_privacy_test.dart \
  test/core/sync/local_state_wiper_test.dart \
  test/core/sync/meaningful_progress_test.dart \
  test/core/sync/cloud_progress_gateway_test.dart
```

Expected: all pass.

- [ ] **Step 2: Run formatting and diff checks**

```bash
dart format --output=none --set-exit-if-changed \
  lib/core/auth/account_transition_gateway.dart \
  lib/core/auth/auth.dart \
  lib/core/auth/auth_repository.dart \
  lib/core/sync/local_state_wiper.dart \
  lib/core/sync/cloud_progress_gateway.dart \
  test/core/auth/auth_repository_sign_out_test.dart \
  test/core/auth/auth_repository_collision_test.dart \
  test/core/auth/auth_repository_privacy_test.dart \
  test/core/sync/local_state_wiper_test.dart \
  test/core/sync/meaningful_progress_test.dart \
  test/core/sync/cloud_progress_gateway_test.dart

git diff --check 0cfb08f6a7e83063af46f020de543af7dcf99ad5...HEAD

dart run tool/check_no_ai_attribution.dart
```

Expected: all pass.

- [ ] **Step 3: Verify scope**

```bash
git diff --name-only 0cfb08f6a7e83063af46f020de543af7dcf99ad5...HEAD
```

Expected paths are only the two coordinator docs plus the implementation/test paths explicitly listed in Tasks 1-3.

- [ ] **Step 4: Hand back without merging**

Report final SHA, commit list, changed paths, exact focused-test result, formatter/diff/no-AI results, and clean status. Push only `codex/firebase-runtime-account-boundary-r2`. Do not open a PR and do not merge into `codex/firebase-runtime-integration` or `main`.
