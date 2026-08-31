# Firebase Runtime Wave 2E-2 — Sync Backend and Rules Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the generation-activation backend, named-Pro Firestore authorization, and safe cleanup required by the Wave 2E Sync client without deploying production Firebase state.

**Architecture:** The client may create and upload an owned staging generation, but only a callable Function may atomically make it active. Firestore rules gate Sync control/generation data to the named Pro owner, distinguish active versus staging writes, and keep the universal user root under the separate account-metadata policy. Scheduled cleanup removes 90-day tombstones, 7-day abandoned staging generations, and 30-day retired generations while rechecking the active pointer immediately before destructive generation cleanup.

**Tech Stack:** Firebase Functions v2, Node 20, TypeScript, Firestore security rules, Firebase Emulator Suite, Node built-in test runner. Pure TypeScript policy tests are compiled in isolation to a temporary directory because the repository's historical `functions/package.json` does not currently provide a TypeScript build/test script.

**Spec:** `docs/superpowers/specs/2026-08-28-firebase-runtime-sync-r1-design.md`

## Global Constraints

- Start from the exact coordinator planning SHA named in the worker prompt. The coordinator keeps `codex/firebase-runtime-integration` pinned to that SHA until both parallel workers hand back.
- Do not modify Dart/Flutter runtime implementation in 2E-2.
- `/users/{uid}` remains named-account metadata and is not Pro backup storage.
- Anonymous and named-Free users cannot read or write Sync control/generation data.
- Named Pro owners may access only their own permitted Sync state/generation data.
- Client code may create/upload a staging generation but may not activate it or change generation status.
- Normal client mutation targets only the active generation; constrained staging writes exist only to build a replacement snapshot before activation.
- Activation is backend-owned, compare-and-swap guarded by the expected active generation, and idempotent if the requested target is already active.
- Cleanup retention is exact: tombstones 90 days, abandoned staging generations 7 days, retired generations 30 days.
- Cleanup never deletes the current active generation and rechecks the active pointer immediately before recursive deletion.
- Preserve existing non-Sync rules behavior for account-root metadata, Pro content, audit logs, and Wrapped shares.
- Remove the obsolete destructive `resetCloudUserData` endpoint/export once generation activation replaces it.
- Do not deploy Functions/rules, mutate Firebase Console, run GitHub Actions, open a PR, or merge to `main`.
- Do not modify RevenueCat/paywall implementation, Android release/signing, content corpus, Sanity, Play, Remote Config, or telemetry Auth identity.
- Use TDD and task-sized commits.

## Base command used by verification tasks

```bash
BASE="$(git merge-base HEAD origin/codex/firebase-runtime-integration)"
test "$BASE" = "$(git rev-parse origin/codex/firebase-runtime-integration)"
```

If the second command fails, stop and report the moved integration branch.

## File Structure and Ownership

### New files

- `functions/src/activateSyncGeneration.ts` — named-Pro callable and Firestore transaction.
- `functions/src/syncGenerationPolicy.ts` — pure auth/CAS/retention helpers.
- `functions/src/cleanupSyncData.ts` — scheduled tombstone/generation cleanup.
- `functions/test/sync-generation.policy.mjs` — Node tests against an isolated compiled copy of the pure TypeScript policy.
- `functions/test/firestore-sync-rules.rules.mjs` — emulator-backed anonymous/named-Free/named-Pro rules tests.

### Existing files modified by 2E-2

- `firestore.rules`
- `functions/src/index.ts`
- `functions/test/static.test.mjs`
- `test/tool/firebase_rules_layout_test.dart` only if its current flat-Sync layout assertions need to move to generation paths.

### Existing file removed by 2E-2

- `functions/src/resetCloudUserData.ts`

### Explicitly not owned

- `lib/**`
- `test/core/sync/**`
- `test/app/**`
- `test/features/**`
- `pubspec.yaml`
- payment/release/content paths.

---

### Task 1: Freeze named-Pro activation and retention policy as executable pure tests

**Files:**
- Create: `functions/src/syncGenerationPolicy.ts`
- Create: `functions/test/sync-generation.policy.mjs`

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
  | {kind: 'activate'; previousGenerationId: string | null}
  | {kind: 'already-active'}
  | {kind: 'generation-conflict'; activeGenerationId: string | null}
  | {kind: 'invalid-target'};

export function decideActivation(input: ActivationDecisionInput): ActivationDecision;

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

- [ ] **Step 1: Write the policy test first**

`functions/test/sync-generation.policy.mjs` imports the temporary compiled file:

```js
import assert from 'node:assert/strict';
import test from 'node:test';
import {
  assertNamedPro,
  decideActivation,
  generationCleanupEligible,
  TOMBSTONE_RETENTION_DAYS,
  STAGING_RETENTION_DAYS,
  RETIRED_RETENTION_DAYS,
} from './.compiled/syncGenerationPolicy.js';

test('retention constants are exact', () => {
  assert.equal(TOMBSTONE_RETENTION_DAYS, 90);
  assert.equal(STAGING_RETENTION_DAYS, 7);
  assert.equal(RETIRED_RETENTION_DAYS, 30);
});

test('anonymous and named Free identities are rejected', () => {
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

test('same active target is idempotent success', () => {
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

test('different active generation produces conflict', () => {
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

Add exact boundary tests for staging at 6 days 23:59:59 versus 7 days, retired at 29 days 23:59:59 versus 30 days, and tombstone cutoff 90 days.

- [ ] **Step 2: Prove RED with an isolated TypeScript compile command**

From `functions/`:

```bash
rm -rf test/.compiled
npx --yes -p typescript tsc src/syncGenerationPolicy.ts \
  --outDir test/.compiled \
  --target ES2022 \
  --module NodeNext \
  --moduleResolution NodeNext \
  --strict
```

Expected: compiler fails because `src/syncGenerationPolicy.ts` does not exist.

- [ ] **Step 3: Implement the pure policy**

`assertNamedPro` requires UID, rejects `firebase.sign_in_provider == 'anonymous'`, and requires `token.pro === true`. `decideActivation` evaluates same-target idempotency first; otherwise target must be `staging`; then current active ID must equal expected active ID. `generationCleanupEligible` returns false whenever candidate ID equals active ID, even when age/status otherwise qualifies.

- [ ] **Step 4: Compile and run GREEN**

```bash
rm -rf test/.compiled
npx --yes -p typescript tsc src/syncGenerationPolicy.ts \
  --outDir test/.compiled \
  --target ES2022 \
  --module NodeNext \
  --moduleResolution NodeNext \
  --strict
node --test test/sync-generation.policy.mjs
rm -rf test/.compiled
```

Expected: all policy tests pass; temporary compiled output removed.

- [ ] **Step 5: Commit**

```bash
git add functions/src/syncGenerationPolicy.ts functions/test/sync-generation.policy.mjs
git commit -m "test(functions): freeze sync generation policy"
```

### Task 2: Replace destructive reset with idempotent generation activation

**Files:**
- Create: `functions/src/activateSyncGeneration.ts`
- Modify: `functions/src/index.ts`
- Modify: `functions/test/static.test.mjs`
- Remove: `functions/src/resetCloudUserData.ts`
- Test: `functions/test/sync-generation.policy.mjs`

**Callable request:**

```ts
interface ActivateSyncGenerationRequest {
  generationId: string;
  expectedActiveGenerationId: string | null;
}
```

**Success response:**

```ts
interface ActivateSyncGenerationResponse {
  activeGenerationId: string;
  alreadyActive: boolean;
}
```

Stable errors:
- missing/anonymous/Free auth: `permission-denied`;
- malformed generation ID: `invalid-argument`;
- missing or non-staging target: `failed-precondition` with detail code `invalid-generation`;
- current/expected mismatch: `failed-precondition` with detail code `generation-conflict` and actual active generation ID.

- [ ] **Step 1: Extend static tests before source changes**

Add source assertions:

```js
assert.match(source, /onCall/);
assert.match(source, /enforceAppCheck:\s*true/);
assert.match(source, /runTransaction/);
assert.match(source, /assertNamedPro/);
assert.match(source, /generation-conflict/);
assert.match(source, /sync_state/);
assert.match(source, /sync_generations/);
assert.doesNotMatch(indexSource, /resetCloudUserData/);
assert.match(indexSource, /activateSyncGeneration/);
```

Also assert activation source updates target `active`, previous generation `retired`, and current pointer inside the transaction.

- [ ] **Step 2: Run RED**

```bash
cd functions
npm test
```

Expected: static activation/export assertions fail.

- [ ] **Step 3: Implement callable transaction**

Use region `asia-southeast1` and `enforceAppCheck: true`. Inside one Firestore transaction:

1. read `users/<uid>/sync_state/current`;
2. read `users/<uid>/sync_generations/<generationId>`;
3. call `decideActivation`;
4. return idempotent success when target is already current/active;
5. throw structured `HttpsError` for invalid/conflict decisions;
6. update target to `status: 'active'`, `activatedAt: FieldValue.serverTimestamp()`;
7. when a previous different generation exists, set it `status: 'retired'`, `retiredAt: FieldValue.serverTimestamp()`;
8. set `sync_state/current` to `activeGenerationId`, `schemaVersion: 1`, `updatedAt: FieldValue.serverTimestamp()`.

After successful transaction, write audit event `syncGenerationActivated`. Delete `resetCloudUserData.ts` and remove its export. No destructive replacement endpoint remains.

- [ ] **Step 4: Run GREEN plus pure policy tests**

```bash
cd functions
npm test
rm -rf test/.compiled
npx --yes -p typescript tsc src/syncGenerationPolicy.ts --outDir test/.compiled --target ES2022 --module NodeNext --moduleResolution NodeNext --strict
node --test test/sync-generation.policy.mjs
rm -rf test/.compiled
```

- [ ] **Step 5: Commit**

```bash
git add functions/src/activateSyncGeneration.ts functions/src/index.ts functions/src/resetCloudUserData.ts functions/test/static.test.mjs
git commit -m "feat(functions): activate staged sync generations"
```

### Task 3: Gate Sync generations to the named Pro owner in Firestore rules

**Files:**
- Modify: `firestore.rules`
- Create: `functions/test/firestore-sync-rules.rules.mjs`
- Modify: `test/tool/firebase_rules_layout_test.dart` only if existing flat-Sync assertions require replacement.

**Rule helpers:**

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

Client contract:
- `/users/{uid}` keeps current named-owner account metadata behavior.
- `/users/{uid}/sync_state/current`: named Pro owner may read; client writes denied.
- `/users/{uid}/sync_generations/{generationId}`: named Pro owner may read; create only as constrained `staging`; client updates may change only `preferences` while active or staging; client cannot change status/timestamps/creator/schema fields.
- Generation collection rows: named Pro owner may read; writes only in active or staging generation.
- Anonymous/named-Free/other UID denied.

Sync row create/update requires:

```text
updatedAt == request.time
originDeviceId is non-empty string
mutationId is non-empty string
schemaVersion == 1
deleted is bool
```

- [ ] **Step 1: Write emulator tests first**

`functions/test/firestore-sync-rules.rules.mjs` uses:

```js
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
```

Seed control/generation docs through `withSecurityRulesDisabled`. Create contexts:

```js
const anonymous = testEnv.authenticatedContext('anon', {
  firebase: {sign_in_provider: 'anonymous'}, pro: true,
});
const namedFree = testEnv.authenticatedContext('free', {
  firebase: {sign_in_provider: 'google.com'}, pro: false,
});
const namedPro = testEnv.authenticatedContext('pro', {
  firebase: {sign_in_provider: 'google.com'}, pro: true,
});
const otherPro = testEnv.authenticatedContext('other', {
  firebase: {sign_in_provider: 'google.com'}, pro: true,
});
```

Required tests:
- anonymous Sync read/write fail;
- named-Free Sync read/write fail;
- other named Pro against owner UID fails;
- owner named Pro reads control/current generation;
- client write to `sync_state/current` fails;
- constrained staging generation create succeeds;
- client create with `status: active` fails;
- staging row write with exact metadata succeeds;
- active row write succeeds;
- retired row write fails;
- malformed metadata write fails;
- client status mutation fails;
- preferences-only update on active generation succeeds;
- existing `/users/{uid}` account-root named-owner behavior remains unchanged and is not made Pro-only.

- [ ] **Step 2: Install local-only harness packages and prove RED**

From repository root:

```bash
cd functions
npm install --no-save --package-lock=false @firebase/rules-unit-testing firebase
cd ..
npx --yes firebase-tools emulators:exec \
  --project pantas-wave2e-test \
  --only firestore \
  "node --test functions/test/firestore-sync-rules.rules.mjs"
```

Expected: generation tests fail under the current flat named-user rules.

- [ ] **Step 3: Implement only the Sync rules restructuring**

Keep unrelated rule sections semantically unchanged. Enumerate these generation subcollections instead of adding a broad recursive allow:

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

The staging generation document create contract requires only frozen fields such as `status`, `schemaVersion`, `createdAt`, `createdByDeviceId`, `preferences`; require `status == 'staging'`, `schemaVersion == 1`, and `createdAt == request.time`. Client generation updates may affect only `preferences`, never status/lifecycle metadata.

- [ ] **Step 4: Run emulator GREEN and static layout tests**

```bash
npx --yes firebase-tools emulators:exec \
  --project pantas-wave2e-test \
  --only firestore \
  "node --test functions/test/firestore-sync-rules.rules.mjs"
flutter test --no-test-assets test/tool/firebase_rules_layout_test.dart
```

Expected: pass.

- [ ] **Step 5: Commit**

```bash
git add firestore.rules functions/test/firestore-sync-rules.rules.mjs test/tool/firebase_rules_layout_test.dart
git commit -m "feat(firebase): gate sync generations to named Pro"
```

### Task 4: Add 90/7/30 cleanup with active-pointer recheck

**Files:**
- Create: `functions/src/cleanupSyncData.ts`
- Modify: `functions/src/index.ts`
- Modify: `functions/test/static.test.mjs`
- Modify: `functions/src/syncGenerationPolicy.ts`
- Test: `functions/test/sync-generation.policy.mjs`

- [ ] **Step 1: Extend RED policy/static tests**

Pure policy boundaries must assert staging becomes eligible at 7 days, retired at 30 days, current active ID always prevents cleanup, and `cutoffDate(now, 90)` is exactly 90 days before `now`.

Static source checks must prove cleanup reads `sync_state/current` again immediately before `recursiveDelete` and compares the freshly read active generation ID against the candidate ID.

- [ ] **Step 2: Run RED**

```bash
cd functions
npm test
rm -rf test/.compiled
npx --yes -p typescript tsc src/syncGenerationPolicy.ts --outDir test/.compiled --target ES2022 --module NodeNext --moduleResolution NodeNext --strict
node --test test/sync-generation.policy.mjs
rm -rf test/.compiled
```

- [ ] **Step 3: Implement scheduled cleanup**

Create a daily scheduled Function in `asia-southeast1`.

For tombstones, loop the ten Sync collection names and run collection-group queries for `deleted == true` with `updatedAt <= 90-day cutoff`; delete in write batches of at most 500.

For generation cleanup, query `sync_generations` collection-group candidates by status/time. Before recursive deletion of each generation:

1. derive UID from the generation document path;
2. server-read `users/<uid>/sync_state/current` again;
3. skip if fresh `activeGenerationId` equals candidate generation ID;
4. server-read the candidate generation again;
5. re-run age/status eligibility;
6. only then call `recursiveDelete`.

Never delete the account root or current control document.

- [ ] **Step 4: Run GREEN**

```bash
cd functions
npm test
rm -rf test/.compiled
npx --yes -p typescript tsc src/syncGenerationPolicy.ts --outDir test/.compiled --target ES2022 --module NodeNext --moduleResolution NodeNext --strict
node --test test/sync-generation.policy.mjs
rm -rf test/.compiled
```

- [ ] **Step 5: Commit**

```bash
git add functions/src/cleanupSyncData.ts functions/src/index.ts functions/src/syncGenerationPolicy.ts functions/test/static.test.mjs functions/test/sync-generation.policy.mjs
git commit -m "feat(functions): clean stale sync data safely"
```

### Task 5: Complete 2E-2 verification and hand back a clean branch

**Files:** No new production scope. Repair only defects exposed by these gates and stay within backend/rules ownership.

- [ ] **Step 1: Re-establish exact base**

```bash
BASE="$(git merge-base HEAD origin/codex/firebase-runtime-integration)"
test "$BASE" = "$(git rev-parse origin/codex/firebase-runtime-integration)"
```

- [ ] **Step 2: Run existing Functions static/unit suite**

```bash
cd functions
npm test
```

Expected: zero failures.

- [ ] **Step 3: Compile/run pure generation policy suite**

```bash
rm -rf test/.compiled
npx --yes -p typescript tsc src/syncGenerationPolicy.ts --outDir test/.compiled --target ES2022 --module NodeNext --moduleResolution NodeNext --strict
node --test test/sync-generation.policy.mjs
rm -rf test/.compiled
```

Expected: all auth/CAS/retention policy tests pass.

- [ ] **Step 4: Run Firestore emulator rules suite**

From repository root:

```bash
cd functions
npm install --no-save --package-lock=false @firebase/rules-unit-testing firebase
cd ..
npx --yes firebase-tools emulators:exec \
  --project pantas-wave2e-test \
  --only firestore \
  "node --test functions/test/firestore-sync-rules.rules.mjs"
```

Expected: all anonymous/named-Free/named-Pro, owner, active/staging/retired, metadata, and account-root regression cases pass.

- [ ] **Step 5: Run repository Firebase static checks**

```bash
flutter test --no-test-assets test/tool/firebase_rules_layout_test.dart test/tool/firebase_setup_docs_test.dart
```

Expected: pass. Do not change Firebase project/console setup in response.

- [ ] **Step 6: Attempt whole Functions TypeScript check without widening scope**

```bash
cd functions
npx tsc --noEmit
```

Expected if the worktree has the repository's Firebase TypeScript dependencies available: exit 0. If it fails solely because this historical Functions package does not declare/install the Firebase runtime dependencies needed by all existing `.ts` files, capture the exact diagnostics and classify that as a pre-existing package/tooling blocker. Do not turn 2E-2 into package-management migration. Any syntax/type defect attributable to changed files must still be repaired.

- [ ] **Step 7: Run hygiene and ownership checks**

```bash
cd ..
git diff --check "$BASE"...HEAD
dart run tool/check_no_ai_attribution.dart
rm -rf functions/node_modules functions/test/.compiled
git status --short --untracked-files=all
```

Then prove no runtime Dart ownership leak:

```bash
if git diff --name-only "$BASE"...HEAD | grep -E '^(lib/|test/core/sync/|test/app/|test/features/)'; then
  echo 'STOP: Dart-runtime-owned path changed'
  exit 1
fi
```

`test/tool/firebase_rules_layout_test.dart` is permitted. Inspect full path list for all other prohibited ownership.

- [ ] **Step 8: Confirm obsolete reset endpoint is absent**

```bash
test ! -e functions/src/resetCloudUserData.ts
! grep -R "resetCloudUserData" functions/src functions/test
```

Expected: pass.

- [ ] **Step 9: Final handback**

Report exact starting/final SHA, commit list/messages, changed paths, Functions test totals, pure policy test totals, emulator rules totals, Firebase static-test results, TypeScript check result or exact pre-existing dependency-blocker classification, retention 90/7/30 proof, active-generation cleanup recheck proof, diff-check/no-AI/ownership results, final tracked status, and confirmation of no Firebase deploy/Console mutation, PR/merge, Actions, Google/Play/Sanity mutation.

Do not merge or fast-forward integration yourself.
