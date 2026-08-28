# Firebase Runtime Wave 2E-2 — Sync Backend and Rules Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the generation-activation backend, named-Pro Firestore authorization, and safe cleanup required by the Wave 2E Sync client without deploying any production Firebase state.

**Architecture:** The client may create/upload an owned staging generation, but only a callable Cloud Function may atomically make it active. Firestore rules gate all Sync control/generation data to the named Pro owner, distinguish active versus staging writes, and keep the universal user root under its separate account-metadata policy. A scheduled cleanup removes 90-day tombstones, 7-day abandoned staging generations, and 30-day retired generations while rechecking the active pointer immediately before destructive generation cleanup.

**Tech Stack:** Firebase Functions v2, Node 20, TypeScript, Firestore security rules, Firebase Emulator Suite, Node built-in test runner, `@firebase/rules-unit-testing` used only by the local rules harness.

**Spec:** `docs/superpowers/specs/2026-08-28-firebase-runtime-sync-r1-design.md`

## Global Constraints

- Implementation branch must start from the exact coordinator planning SHA supplied in the worker prompt.
- Do not modify Dart/Flutter runtime files in 2E-2.
- `/users/{uid}` remains named-account metadata and is not Pro backup storage.
- Anonymous and named-Free users must not read or write Sync control/generation data.
- Named Pro owners may access only their own Sync state and permitted generation data.
- Client code may create/upload a staging generation but may not activate it or mutate generation status fields.
- Normal client mutation targets only the active generation; staging writes are allowed only for the caller's own constrained staging generation.
- Activation is backend-owned, uses compare-and-swap against the expected active generation, and is idempotent when the requested target is already active.
- Cleanup retention is exact: tombstones 90 days, abandoned staging generations 7 days, retired generations 30 days.
- Cleanup never deletes the generation currently referenced by `sync_state/current`; recheck immediately before recursive deletion.
- Preserve existing non-Sync Firestore rules such as account-root metadata, Pro content, audit logs, and Wrapped shares unless a direct syntax restructuring is required with identical behavior.
- Remove the obsolete destructive `resetCloudUserData` export/function once activation replaces it.
- Do not deploy Functions or Firestore rules, mutate Firebase Console, run GitHub Actions, open a PR, or merge to `main`.
- Do not modify RevenueCat/paywall implementation, Android release/signing, content corpus, Sanity, Play, Remote Config, or telemetry Auth identity.
- Use TDD and task-sized commits.

## File Structure and Ownership

### New files

- `functions/src/activateSyncGeneration.ts` — named-Pro callable and Firestore transaction.
- `functions/src/syncGenerationPolicy.ts` — pure request/auth/CAS helpers and retention constants used by unit tests.
- `functions/src/cleanupSyncData.ts` — scheduled tombstone/generation cleanup.
- `functions/test/sync-generation.test.mjs` — pure/static Function contract tests.
- `functions/test/firestore-sync-rules.test.mjs` — emulator-backed anonymous/named-Free/named-Pro rules tests.

### Existing files modified by 2E-2

- `firestore.rules`
- `functions/src/index.ts`
- `functions/test/static.test.mjs`
- `functions/package.json` only if a local rules-test script is useful; do not introduce runtime dependency churn.

### Existing file removed by 2E-2

- `functions/src/resetCloudUserData.ts`

---

### Task 1: Freeze activation authorization and compare-and-swap behavior in pure tests

**Files:**
- Create: `functions/src/syncGenerationPolicy.ts`
- Create: `functions/test/sync-generation.test.mjs`

**Interfaces:**

```ts
export const TOMBSTONE_RETENTION_DAYS = 90;
export const STAGING_RETENTION_DAYS = 7;
export const RETIRED_RETENTION_DAYS = 30;

export interface SyncAuthLike {
  uid: string;
  token: Record<string, unknown>;
}

export function assertNamedPro(auth: SyncAuthLike | undefined): string;

export interface ActivationDecisionInput {
  currentGenerationId: string | null;
  expectedActiveGenerationId: string | null;
  requestedGenerationId: string;
  requestedGenerationStatus: string | null;
}

export type ActivationDecision =
  | { kind: 'activate'; previousGenerationId: string | null }
  | { kind: 'already-active' }
  | { kind: 'generation-conflict'; activeGenerationId: string | null }
  | { kind: 'invalid-target' };

export function decideActivation(input: ActivationDecisionInput): ActivationDecision;
```

- [ ] **Step 1: Write pure RED tests**

```js
import assert from 'node:assert/strict';
import test from 'node:test';
import {
  assertNamedPro,
  decideActivation,
  TOMBSTONE_RETENTION_DAYS,
  STAGING_RETENTION_DAYS,
  RETIRED_RETENTION_DAYS,
} from '../src/syncGenerationPolicy.js';

test('retention constants are frozen', () => {
  assert.equal(TOMBSTONE_RETENTION_DAYS, 90);
  assert.equal(STAGING_RETENTION_DAYS, 7);
  assert.equal(RETIRED_RETENTION_DAYS, 30);
});

test('anonymous and named Free are rejected', () => {
  assert.throws(() => assertNamedPro(undefined));
  assert.throws(() => assertNamedPro({
    uid: 'u1',
    token: {firebase: {sign_in_provider: 'anonymous'}, pro: true},
  }));
  assert.throws(() => assertNamedPro({
    uid: 'u1',
    token: {firebase: {sign_in_provider: 'google.com'}, pro: false},
  }));
});

test('matching expected generation activates staging target', () => {
  assert.deepEqual(
    decideActivation({
      currentGenerationId: 'old',
      expectedActiveGenerationId: 'old',
      requestedGenerationId: 'new',
      requestedGenerationStatus: 'staging',
    }),
    {kind: 'activate', previousGenerationId: 'old'},
  );
});

test('same already-active target is idempotent success', () => {
  assert.deepEqual(
    decideActivation({
      currentGenerationId: 'new',
      expectedActiveGenerationId: 'old',
      requestedGenerationId: 'new',
      requestedGenerationStatus: 'active',
    }),
    {kind: 'already-active'},
  );
});

test('different active generation is a conflict', () => {
  assert.deepEqual(
    decideActivation({
      currentGenerationId: 'other',
      expectedActiveGenerationId: 'old',
      requestedGenerationId: 'new',
      requestedGenerationStatus: 'staging',
    }),
    {kind: 'generation-conflict', activeGenerationId: 'other'},
  );
});
```

- [ ] **Step 2: Run RED**

```bash
cd functions
npm test
```

Expected: new test cannot load the missing policy module.

- [ ] **Step 3: Implement the pure policy**

`assertNamedPro` must require a UID, reject `firebase.sign_in_provider == 'anonymous'`, and require `token.pro === true`. `decideActivation` must check already-active idempotency first, then require target status `staging`, then compare current versus expected. Do not put Firestore I/O into this file.

- [ ] **Step 4: Run GREEN**

```bash
cd functions
npm test
```

Expected: all existing tests plus the new policy tests pass.

- [ ] **Step 5: Commit**

```bash
git add functions/src/syncGenerationPolicy.ts functions/test/sync-generation.test.mjs
git commit -m "test(functions): freeze sync generation policy"
```

### Task 2: Replace destructive cloud reset with idempotent generation activation

**Files:**
- Create: `functions/src/activateSyncGeneration.ts`
- Modify: `functions/src/index.ts`
- Modify: `functions/test/static.test.mjs`
- Remove: `functions/src/resetCloudUserData.ts`
- Test: `functions/test/sync-generation.test.mjs`

**Interfaces:**

Callable request:

```ts
interface ActivateSyncGenerationRequest {
  generationId: string;
  expectedActiveGenerationId: string | null;
}
```

Success response:

```ts
interface ActivateSyncGenerationResponse {
  activeGenerationId: string;
  alreadyActive: boolean;
}
```

Stable failures:
- unauthenticated/anonymous/Free: `permission-denied`;
- malformed/missing generation ID: `invalid-argument`;
- missing or non-staging target: `failed-precondition` with detail code `invalid-generation`;
- expected-current mismatch: `failed-precondition` with detail code `generation-conflict` and actual `activeGenerationId`.

- [ ] **Step 1: Extend RED static tests**

Assert source contains:

```js
assert.match(source, /onCall/);
assert.match(source, /enforceAppCheck:\s*true/);
assert.match(source, /runTransaction/);
assert.match(source, /assertNamedPro/);
assert.match(source, /generation-conflict/);
assert.doesNotMatch(indexSource, /resetCloudUserData/);
assert.match(indexSource, /activateSyncGeneration/);
```

Also assert the transaction writes `sync_state/current`, marks target `active`, and marks the previous active generation `retired` when one exists.

- [ ] **Step 2: Run RED**

```bash
cd functions
npm test
```

- [ ] **Step 3: Implement the callable**

Use region `asia-southeast1` and `enforceAppCheck: true`. Inside one Firestore transaction:

1. read `users/<uid>/sync_state/current`;
2. read `users/<uid>/sync_generations/<generationId>`;
3. call `decideActivation`;
4. return idempotent success if already active;
5. throw structured `HttpsError` for invalid/conflict decisions;
6. update target to `status: 'active'`, `activatedAt: FieldValue.serverTimestamp()`;
7. if previous generation exists and differs, update it to `status: 'retired'`, `retiredAt: FieldValue.serverTimestamp()`;
8. set `sync_state/current` with `activeGenerationId`, `schemaVersion: 1`, `updatedAt: FieldValue.serverTimestamp()`.

After a successful transaction, write audit event `syncGenerationActivated` with the UID. A retry whose target is already active returns success so a lost HTTP response cannot strand the client in a false conflict.

Delete `resetCloudUserData.ts` and its export. Do not leave a second destructive replacement endpoint.

- [ ] **Step 4: Run GREEN**

```bash
cd functions
npm test
```

Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
git add functions/src/activateSyncGeneration.ts functions/src/index.ts functions/src/resetCloudUserData.ts functions/test/static.test.mjs functions/test/sync-generation.test.mjs
git commit -m "feat(functions): activate staged sync generations"
```

### Task 3: Rewrite only the Sync portion of Firestore rules for named-Pro generations

**Files:**
- Modify: `firestore.rules`
- Create: `functions/test/firestore-sync-rules.test.mjs`

**Interfaces / rule helpers:**

Use helpers with these semantics:

```text
isSignedIn()
isNamedUser()
isOwner(uid)
isProUser()
isProOwner(uid)
activeGenerationId(uid)
isActiveGeneration(uid, generationId)
isStagingGeneration(uid, generationId)
```

Client ownership contract:
- `/users/{uid}` stays readable by named owner under existing account metadata policy.
- `/users/{uid}/sync_state/current`: named Pro owner read; client write false.
- `/users/{uid}/sync_generations/{generationId}`: named Pro owner may read; create only with exact required staging fields and `status == 'staging'`; updates may change only `preferences` while generation is active or staging; client cannot change status/timestamps/creator/schema fields.
- generation subcollection data: named Pro owner may read; writes only when generation is active or staging.
- anonymous and named-Free users receive no Sync read/write access.

Required Sync row metadata on create/update:

```text
updatedAt
originDeviceId
mutationId
schemaVersion
deleted
```

For writes, require `updatedAt == request.time`, `originDeviceId` and `mutationId` non-empty strings, `schemaVersion == 1`, and `deleted` boolean. Tombstone writes may omit domain payload but must preserve this metadata contract.

- [ ] **Step 1: Write emulator tests before editing rules**

Use `@firebase/rules-unit-testing`:

```js
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
```

Seed control/generation documents with `testEnv.withSecurityRulesDisabled`. Create contexts:

```js
const anonymous = testEnv.authenticatedContext('anon', {
  firebase: {sign_in_provider: 'anonymous'},
  pro: true,
});
const namedFree = testEnv.authenticatedContext('free', {
  firebase: {sign_in_provider: 'google.com'},
  pro: false,
});
const namedPro = testEnv.authenticatedContext('pro', {
  firebase: {sign_in_provider: 'google.com'},
  pro: true,
});
const otherPro = testEnv.authenticatedContext('other', {
  firebase: {sign_in_provider: 'google.com'},
  pro: true,
});
```

Tests must prove:
- anonymous read/write Sync denied;
- named-Free read/write Sync denied;
- other named Pro denied against owner UID;
- owner named Pro reads control/current generation;
- client cannot write `sync_state/current`;
- owner named Pro creates constrained staging generation;
- client cannot create `active` generation directly;
- staging row write succeeds with exact metadata;
- active row write succeeds with exact metadata;
- retired generation row write fails;
- malformed metadata write fails;
- client cannot change generation `status`;
- preferences-only update on active generation succeeds;
- existing `/users/{uid}` account-root behavior remains named-owner based and does not become Pro-only.

- [ ] **Step 2: Install local-only test packages and prove RED**

Do not commit dependency files for this harness. From `functions/`:

```bash
npm install --no-save --package-lock=false @firebase/rules-unit-testing firebase
cd ..
npx --yes firebase-tools emulators:exec --project pantas-wave2e-test --only firestore "node --test functions/test/firestore-sync-rules.test.mjs"
```

Expected: new generation rule tests fail under the current flat named-user Sync rules.

- [ ] **Step 3: Implement rule helpers and generation matches**

Keep non-Sync sections semantically unchanged. Replace flat progress collection matches under `/users/{uid}` with `sync_state`, `sync_generations`, and nested generation collection matches. Do not grant a broad recursive `/{document=**}` allow under a generation; enumerate the ten active Sync collection names so absent/future collections stay denied by default:

```text
quiz_attempts
assessments
fsrs_cards
lesson_progress
lesson_bookmarks
question_flags
mock_exam_attempts
review_logs
track_scope
custom_blueprints
```

- [ ] **Step 4: Run emulator GREEN**

```bash
npx --yes firebase-tools emulators:exec --project pantas-wave2e-test --only firestore "node --test functions/test/firestore-sync-rules.test.mjs"
```

Expected: all rules tests pass.

- [ ] **Step 5: Run static rule/layout checks**

```bash
flutter test --no-test-assets test/tool/firebase_rules_layout_test.dart
```

Update that existing static test only if it asserts the superseded flat Sync layout; preserve checks for unrelated rules.

- [ ] **Step 6: Commit**

```bash
git add firestore.rules functions/test/firestore-sync-rules.test.mjs test/tool/firebase_rules_layout_test.dart
git commit -m "feat(firebase): gate sync generations to named Pro"
```

### Task 4: Add tombstone and generation cleanup with active-pointer recheck

**Files:**
- Create: `functions/src/cleanupSyncData.ts`
- Modify: `functions/src/index.ts`
- Modify: `functions/test/static.test.mjs`
- Test: `functions/test/sync-generation.test.mjs`

**Interfaces:**

```ts
export function cutoffDate(now: Date, days: number): Date;
export function generationCleanupEligible(input: {
  generationId: string;
  status: string;
  createdAt?: Date;
  retiredAt?: Date;
  activeGenerationId: string | null;
  now: Date;
}): boolean;
```

Scheduled cleanup must run server-side and does not depend on a client being online.

- [ ] **Step 1: Add RED retention/pointer tests**

```js
test('active generation is never cleanup eligible', () => {
  assert.equal(generationCleanupEligible({
    generationId: 'g1',
    status: 'retired',
    retiredAt: new Date('2026-01-01T00:00:00Z'),
    activeGenerationId: 'g1',
    now: new Date('2026-08-28T00:00:00Z'),
  }), false);
});
```

Add tests for staging at 6/7 days, retired at 29/30 days, and tombstone cutoff exactly 90 days.

Static test must assert `cleanupSyncData.ts` performs a fresh read of `sync_state/current` immediately before `recursiveDelete` and compares its active ID against the candidate generation ID.

- [ ] **Step 2: Run RED**

```bash
cd functions
npm test
```

- [ ] **Step 3: Implement cleanup**

Use a daily scheduled Function in `asia-southeast1`. For each Sync collection name, collection-group query tombstones with `deleted == true` and `updatedAt <= 90-day cutoff`; delete in batches of at most 500 operations.

For generation cleanup, query `sync_generations` collection-group candidates by status/time. Before recursive deletion of each generation:

1. derive parent UID from the generation document path;
2. server-read `users/<uid>/sync_state/current` again;
3. skip if its `activeGenerationId` equals the candidate ID;
4. server-read the generation doc again and re-evaluate age/status;
5. only then call `recursiveDelete` on the generation reference.

Do not delete the account root or `sync_state/current`.

- [ ] **Step 4: Run GREEN**

```bash
cd functions
npm test
```

- [ ] **Step 5: Commit**

```bash
git add functions/src/cleanupSyncData.ts functions/src/index.ts functions/src/syncGenerationPolicy.ts functions/test/static.test.mjs functions/test/sync-generation.test.mjs
git commit -m "feat(functions): clean stale sync data safely"
```

### Task 5: Run complete 2E-2 verification and produce a clean handback

**Files:** No new scope. Repair only defects exposed by these gates and stay within backend/rules ownership.

- [ ] **Step 1: Run Functions tests**

```bash
cd functions
npm test
```

Expected: 0 failures, 0 skipped/cancelled unexpected tests.

- [ ] **Step 2: Run Firestore emulator rules suite**

From repository root:

```bash
cd functions
npm install --no-save --package-lock=false @firebase/rules-unit-testing firebase
cd ..
npx --yes firebase-tools emulators:exec --project pantas-wave2e-test --only firestore "node --test functions/test/firestore-sync-rules.test.mjs"
```

Expected: all anonymous/named-Free/named-Pro, active/staging/retired, metadata, and account-root regression cases pass.

- [ ] **Step 3: Run repository static rule/setup tests**

```bash
flutter test --no-test-assets test/tool/firebase_rules_layout_test.dart test/tool/firebase_setup_docs_test.dart
```

Expected: pass. Do not change Firebase project/console setup in response to these tests.

- [ ] **Step 4: Type-check Functions if the worktree has the repository's required Firebase TypeScript dependencies available**

```bash
cd functions
npx tsc --noEmit
```

Expected: exit 0. If the command fails solely because this historical functions package does not declare/install its Firebase runtime dependencies, report that exact infrastructure limitation separately; do not widen Wave 2E-2 into an unrelated package-management migration. Syntax/logic defects in changed files must still be repaired.

- [ ] **Step 5: Run diff/hygiene checks**

```bash
git diff --check <WORKER_BASE_SHA>...HEAD
dart run tool/check_no_ai_attribution.dart
git status --short --untracked-files=all
```

Replace `<WORKER_BASE_SHA>` with the exact base SHA from the worker prompt. Remove local-only `functions/node_modules` before the final status check.

- [ ] **Step 6: Prove ownership boundary**

```bash
git diff --name-only <WORKER_BASE_SHA>...HEAD | grep -E '^(lib/|test/core/sync/|test/app/|test/features/)' && exit 1 || true
```

`test/tool/firebase_rules_layout_test.dart` is the only permitted Dart-side test path for this worker. No `lib/**` changes are permitted.

- [ ] **Step 7: Confirm obsolete destructive endpoint is gone**

```bash
test ! -e functions/src/resetCloudUserData.ts
! grep -R "resetCloudUserData" functions/src functions/test
```

Expected: pass.

- [ ] **Step 8: Final handback**

Report:
- exact starting SHA and final SHA;
- commit list/messages;
- changed paths;
- Functions test totals;
- emulator rules test totals;
- static Firebase test results;
- TypeScript check result or exact pre-existing dependency blocker classification;
- retention constants 90/7/30 confirmation;
- active-generation cleanup recheck proof;
- `git diff --check` result;
- no-AI result;
- ownership/prohibited-path result;
- final tracked status;
- confirmation that no Firebase deploy/Console mutation, PR/merge, Actions, Google/Play/Sanity mutation occurred.

Do not merge or fast-forward integration yourself.
