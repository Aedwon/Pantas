# Firebase Runtime Wave 2E-1 — Dart Sync Runtime Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the placeholder Sync client with a production named-Pro runtime that performs B3 reconciliation, generation-safe full push/pull, durable offline queueing, stale-base conflict protection, tombstone delete convergence, lifecycle quiescence, and app-level reconciliation UI.

**Architecture:** Keep Auth identity-only and evolve the existing `lib/core/sync/` skeleton. Drift stores engine-wide state in `sync_meta`, per-row accepted cloud state in a new `sync_row_meta`, and generation-aware pending mutations in `pending_sync`; Firebase SDK details stay behind Sync-owned gateways. A plain runtime controller combines Auth identity, RevenueCat entitlement bridged from `lib/app/`, and a forced Firebase token-claim refresh; full replacement uses stage/activate generations and download-before-replace, while normal writes use server-ordered LWW with stale-base protection.

**Tech Stack:** Flutter 3.41.9, Dart, Riverpod, Drift/SQLite, `firebase_auth`, `cloud_firestore`, `cloud_functions`, Flutter widget tests.

**Spec:** `docs/superpowers/specs/2026-08-28-firebase-runtime-sync-r1-design.md`

## Global Constraints

- Start from the exact coordinator planning SHA named in the worker prompt. The coordinator keeps `codex/firebase-runtime-integration` pinned to that SHA until both parallel workers hand back.
- Anonymous Free and named Free remain local-only.
- Named Pro Sync eligibility requires named Auth identity + RevenueCat Pro + freshly refreshed Firebase ID-token claim `pro == true`.
- Auth does not inspect cloud progress or perform B3.
- `/users/{uid}` remains account metadata, not Sync generation storage.
- Both-sides-meaningful B3 blocks normal Sync and offers exactly `Keep this device` and `Keep my account`.
- B3 does not perform record-level merge.
- Keep-this-device stages a fresh generation before backend activation; it never delete-then-uploads the active generation.
- Keep-my-account downloads and validates the complete snapshot before one local replacement transaction.
- `sync_meta` remains engine-wide key/value state.
- New `sync_row_meta` stores per-row accepted cloud timestamps/origin metadata.
- Domain tables do not gain new Sync timestamp columns. Existing domain timestamps remain domain fields and are not the Sync LWW clock.
- Pending operations carry generation identity, base cloud timestamp, mutation identity, and local revision.
- Deletes use tombstones. The backend owns physical cleanup after 90 days.
- In-progress mock attempts remain device-local; terminal mock attempts sync.
- Review logs, track scope, and custom blueprints are Sync-owned source data in Wave 2E.
- No idle polling timer and no Sync background isolate.
- Ordinary queue flush debounce is exactly 5 seconds. App-background, manual retry, and Firestore reconnect override the debounce.
- Pro expiry/eligibility loss quiesces without deleting either side; restoration re-runs B3.
- Ordinary Pro sign-out may abort if the required flush fails; account deletion never flushes pending mutations first.
- Do not modify `firestore.rules` or `functions/**` in 2E-1.
- Do not modify RevenueCat/paywall-owned implementation files. `lib/app/` may consume the existing `entitlementProvider` and bridge a feature-neutral boolean into Sync.
- Do not modify Android signing/release, content corpus, Sanity, Remote Config, telemetry Auth identity, or payment product behavior.
- Do not deploy Firebase, run GitHub Actions, open a PR, or merge to `main`.
- Use TDD for every behavior change. Keep commits task-sized.

## Base command used by verification tasks

Every verification block that needs the branch base uses:

```bash
BASE="$(git merge-base HEAD origin/codex/firebase-runtime-integration)"
test "$BASE" = "$(git rev-parse origin/codex/firebase-runtime-integration)"
```

The second command must pass. If integration moved, stop and report instead of measuring against a moving base.

## File Structure and Ownership

### New files

- `lib/core/storage/data/tables/sync_row_meta_table.dart` — structured per-row accepted cloud metadata.
- `lib/core/sync/model/sync_document.dart` — normalized Firestore document and conditional row-commit result types.
- `lib/core/sync/model/sync_generation.dart` — generation control/status and B3 choice/result types.
- `lib/core/sync/engine/sync_collection_adapter.dart` — local-table adapter contract used by registry/bootstrap/pipelines.
- `lib/core/sync/engine/sync_meaningful_progress.dart` — B3-only syncable meaningful-data detector.
- `lib/core/sync/engine/generation_repository.dart` — active/staging generation reads and client staging writes.
- `lib/core/sync/eligibility/sync_claim_gateway.dart` — Firebase Pro-claim refresh seam and live adapter.
- `lib/core/sync/eligibility/sync_entitlement.dart` — feature-neutral entitlement snapshot seam.
- `lib/core/sync/runtime/sync_runtime_controller.dart` — eligibility, B3, engine start/stop, status orchestration.
- `lib/core/sync/runtime/sync_account_transition_gateway.dart` — concrete Auth account-transition adapter.
- `lib/core/sync/firestore/firebase_firestore_gateway.dart` — real Firestore implementation.
- `lib/core/sync/firestore/firebase_sync_functions_gateway.dart` — real `activateSyncGeneration` callable adapter.
- `lib/core/sync/mapping/review_log_mapper.dart`
- `lib/core/sync/mapping/track_scope_mapper.dart`
- `lib/core/sync/mapping/custom_blueprint_mapper.dart`
- `lib/features/settings/presentation/widgets/sync_reconciliation_gate.dart` — app-level blocking B3 UI.
- `lib/app/sync_runtime_bootstrap.dart` — production overrides, provider subscriptions, and lifecycle binding.
- Focused tests mirroring the new source files under `test/core/sync/**`, `test/app/**`, and `test/features/settings/**`.

### Existing files modified by 2E-1

- `lib/core/storage/data/app_database.dart`
- `lib/core/storage/data/tables/pending_sync_table.dart`
- `lib/core/sync/engine/collection_registry.dart`
- `lib/core/sync/engine/pending_queue.dart`
- `lib/core/sync/engine/push_pipeline.dart`
- `lib/core/sync/engine/pull_pipeline.dart`
- `lib/core/sync/engine/sync_engine.dart`
- `lib/core/sync/bootstrap/full_push.dart`
- `lib/core/sync/bootstrap/full_pull.dart`
- `lib/core/sync/firestore/firestore_gateway.dart`
- `lib/core/sync/firestore/functions_gateway.dart`
- `lib/core/sync/cloud_progress_gateway.dart` — move/replace its responsibility inside Sync; it must stop importing Auth.
- `lib/core/sync/providers.dart`
- `lib/core/sync/sync_status.dart`
- `lib/core/sync/sync_coordinator.dart`
- `lib/core/sync/sync.dart`
- existing mapper files only where complete payload round-trips require it.
- `lib/core/auth/auth_repository.dart` — remove only the temporary Auth-side `CloudProgressGateway` compatibility declaration/classes.
- `lib/app/auth_bootstrap.dart` — inject real Sync `AccountTransitionGateway` without reopening Auth behavior.
- `lib/app/bootstrap.dart` — install Sync overrides and bind runtime after RevenueCat bootstrap.
- `lib/app/app.dart` — wrap app child in the reconciliation gate.
- `lib/l10n/app_en.arb` — B3 dialog copy only.

---

### Task 1: Add generation-aware queue metadata and `sync_row_meta`

**Files:**
- Create: `lib/core/storage/data/tables/sync_row_meta_table.dart`
- Modify: `lib/core/storage/data/tables/pending_sync_table.dart`
- Modify: `lib/core/storage/data/app_database.dart`
- Test: `test/core/sync/sync_schema_test.dart`
- Test: `test/core/sync/pending_queue_test.dart`

**Interfaces:**
- Produces Drift table `syncRowMeta` keyed by `(collection, rowId)`.
- Produces pending fields `generationId`, `baseUpdatedAt`, `mutationId`, `revision` consumed by Tasks 5–8.

- [ ] **Step 1: Write the schema tests**

```dart
expect(db.schemaVersion, 23);

final rowMetaColumns = await db
    .customSelect('PRAGMA table_info(sync_row_meta)')
    .get();
expect(
  rowMetaColumns.map((row) => row.data['name']),
  containsAll(['collection', 'row_id', 'updated_at', 'origin_device_id']),
);

final pendingColumns = await db
    .customSelect('PRAGMA table_info(pending_sync)')
    .get();
expect(
  pendingColumns.map((row) => row.data['name']),
  containsAll(['generation_id', 'base_updated_at', 'mutation_id', 'revision']),
);
```

Add a schema-22-to-23 migration test that seeds one domain row, one `sync_meta.deviceId`, and one legacy pending row. After upgrade assert: domain row preserved; `deviceId` preserved; legacy pending queue empty; `sync_row_meta` created.

Add a contract test scanning the relevant domain table definitions and asserting Wave 2E did not add fields named `syncUpdatedAt`, `cloudUpdatedAt`, `originDeviceId`, or `mutationId` to domain tables.

- [ ] **Step 2: Run RED**

```bash
flutter test --no-test-assets test/core/sync/sync_schema_test.dart test/core/sync/pending_queue_test.dart
```

Expected: schema 23/table/columns do not exist.

- [ ] **Step 3: Add the exact table contracts**

```dart
@DataClassName('SyncRowMetaRow')
class SyncRowMeta extends Table {
  TextColumn get collection => text()();
  TextColumn get rowId => text().named('row_id')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  TextColumn get originDeviceId => text().named('origin_device_id')();

  @override
  Set<Column<Object>> get primaryKey => {collection, rowId};
}
```

Extend `PendingSync` with:

```dart
TextColumn get generationId => text().named('generation_id')();
DateTimeColumn get baseUpdatedAt => dateTime().named('base_updated_at').nullable()();
TextColumn get mutationId => text().named('mutation_id')();
IntColumn get revision => integer().withDefault(const Constant(1))();
```

Change the unique index to `(generationId, tableType, rowId)`. Bump `schemaVersion` to 23. In `from < 23`: create `syncRowMeta`; clear the placeholder-era pending queue; add the four pending columns; drop `pending_sync_table_row_idx`; create `pending_sync_generation_table_row_idx` over `(generation_id, table_type, row_id)`. Preserve domain rows and `sync_meta`.

- [ ] **Step 4: Regenerate Drift and run GREEN**

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test --no-test-assets test/core/sync/sync_schema_test.dart test/core/sync/pending_queue_test.dart
```

Expected: pass.

- [ ] **Step 5: Commit**

```bash
git add lib/core/storage/data/tables/sync_row_meta_table.dart lib/core/storage/data/tables/pending_sync_table.dart lib/core/storage/data/app_database.dart lib/core/storage/data/app_database.g.dart test/core/sync/sync_schema_test.dart test/core/sync/pending_queue_test.dart
git commit -m "feat(sync): add row metadata and generation queue"
```

### Task 2: Make the Sync registry represent every backed-up source table

**Files:**
- Create: `lib/core/sync/engine/sync_collection_adapter.dart`
- Create: `lib/core/sync/engine/sync_meaningful_progress.dart`
- Create: `lib/core/sync/mapping/review_log_mapper.dart`
- Create: `lib/core/sync/mapping/track_scope_mapper.dart`
- Create: `lib/core/sync/mapping/custom_blueprint_mapper.dart`
- Modify: `lib/core/sync/engine/collection_registry.dart`
- Modify existing files in `lib/core/sync/mapping/` only when required for complete round-trip payloads.
- Test: `test/core/sync/collection_registry_test.dart`
- Test: `test/core/sync/meaningful_progress_test.dart`
- Test: mapper files under `test/core/sync/mapping/`.

**Interfaces:**

```dart
class SyncLocalRecord {
  const SyncLocalRecord({required this.rowId, required this.data});
  final String rowId;
  final Map<String, Object?> data;
}

abstract interface class SyncCollectionAdapter {
  String get tableType;
  String get firestorePath;
  Future<List<SyncLocalRecord>> readAll(AppDatabase db);
  Future<SyncLocalRecord?> readOne(AppDatabase db, String rowId);
  Future<void> applyUpsert(AppDatabase db, Map<String, Object?> data);
  Future<void> applyDelete(AppDatabase db, String rowId);
  Future<bool> hasMeaningfulData(AppDatabase db);
}
```

- [ ] **Step 1: Freeze registry and B3 meaningful-data expectations**

```dart
expect(
  activeSyncCollections.map((entry) => entry.firestorePath).toSet(),
  {
    'quiz_attempts',
    'assessments',
    'fsrs_cards',
    'lesson_progress',
    'lesson_bookmarks',
    'question_flags',
    'mock_exam_attempts',
    'review_logs',
    'track_scope',
    'custom_blueprints',
  },
);
```

Add tests proving: each listed source table counts as meaningful when it has a syncable row; account preferences alone do not force a B3 conflict; a terminal mock counts; an in-progress mock alone does not count; streak/quiz-session/device-pref/derived metrics alone do not count.

- [ ] **Step 2: Run RED**

```bash
flutter test --no-test-assets test/core/sync/collection_registry_test.dart test/core/sync/meaningful_progress_test.dart test/core/sync/mapping
```

- [ ] **Step 3: Implement adapters/mappers**

Keep mapper responsibility to row ↔ Firestore domain payload conversion and adapter responsibility to database access. For compound-key track scope, freeze stable document IDs as:

```dart
String trackScopeDocumentId(String examId, String topicId) =>
    '${Uri.encodeComponent(examId)}--${Uri.encodeComponent(topicId)}';
```

Terminal mock adapter includes only `completed`, `discarded`, `forfeited` in snapshot/meaningful-data methods. `study_plan` remains inactive because no real table/runtime exists.

- [ ] **Step 4: Run GREEN**

```bash
flutter test --no-test-assets test/core/sync/collection_registry_test.dart test/core/sync/meaningful_progress_test.dart test/core/sync/mapping
```

- [ ] **Step 5: Commit**

```bash
git add lib/core/sync/engine/sync_collection_adapter.dart lib/core/sync/engine/sync_meaningful_progress.dart lib/core/sync/engine/collection_registry.dart lib/core/sync/mapping test/core/sync/collection_registry_test.dart test/core/sync/meaningful_progress_test.dart test/core/sync/mapping
git commit -m "feat(sync): align backed-up collection registry"
```

### Task 3: Add production-capable Firestore and Functions gateways

**Files:**
- Create: `lib/core/sync/model/sync_document.dart`
- Modify: `lib/core/sync/firestore/firestore_gateway.dart`
- Create: `lib/core/sync/firestore/firebase_firestore_gateway.dart`
- Modify: `lib/core/sync/firestore/functions_gateway.dart`
- Create: `lib/core/sync/firestore/firebase_sync_functions_gateway.dart`
- Test: `test/core/sync/firestore_gateway_contract_test.dart`
- Create: `test/core/sync/firebase_firestore_gateway_test.dart`
- Create: `test/core/sync/firebase_sync_functions_gateway_test.dart`

**Interfaces:**

```dart
class SyncDocument {
  const SyncDocument({required this.id, required this.data});
  final String id;
  final Map<String, Object?> data;
  DateTime? get updatedAt => data['updatedAt'] as DateTime?;
}

sealed class RowCommitResult {
  const RowCommitResult();
}
class RowCommitted extends RowCommitResult {
  const RowCommitted(this.authoritative);
  final SyncDocument authoritative;
}
class RowStale extends RowCommitResult {
  const RowStale(this.current);
  final SyncDocument? current;
}

abstract interface class FirestoreGateway {
  Future<void> commitBatch(List<FirestoreWrite> writes);
  Future<List<SyncDocument>> readCollection(String path);
  Future<SyncDocument?> readDocument(String path);
  Stream<List<SyncDocument>> watchCollection(String path);
  Stream<SyncDocument?> watchDocument(String path);
  Future<RowCommitResult> commitRowIfBaseMatches({
    required String path,
    required DateTime? baseUpdatedAt,
    required Map<String, Object?> data,
  });
}
```

`SyncFunctionsGateway` becomes:

```dart
abstract interface class SyncFunctionsGateway {
  Future<void> activateGeneration({
    required String generationId,
    required String? expectedActiveGenerationId,
  });
}
```

- [ ] **Step 1: Write gateway contract tests**

Cover null-base create, matching-base update, stale-base update, missing-current with non-null base, server timestamp normalization, document/collection streams, activation payload, and mapping backend generation conflict to stable client code `generation-conflict`.

- [ ] **Step 2: Run RED**

```bash
flutter test --no-test-assets test/core/sync/firestore_gateway_contract_test.dart test/core/sync/firebase_firestore_gateway_test.dart test/core/sync/firebase_sync_functions_gateway_test.dart
```

- [ ] **Step 3: Implement Firebase adapters**

Use `FirebaseFirestore.instance` and `FirebaseFunctions.instanceFor(region: 'asia-southeast1')`. Convert Firestore `Timestamp` values at the gateway boundary so pipelines see `DateTime`, not Firebase SDK types. `commitRowIfBaseMatches` uses an online Firestore transaction to compare server state; after a successful transaction, perform a server read of that document and return the authoritative document so a sign-out flush can complete without waiting for an asynchronous listener echo.

- [ ] **Step 4: Run GREEN**

```bash
flutter test --no-test-assets test/core/sync/firestore_gateway_contract_test.dart test/core/sync/firebase_firestore_gateway_test.dart test/core/sync/firebase_sync_functions_gateway_test.dart
```

- [ ] **Step 5: Commit**

```bash
git add lib/core/sync/firestore lib/core/sync/model/sync_document.dart test/core/sync/firestore_gateway_contract_test.dart test/core/sync/firebase_firestore_gateway_test.dart test/core/sync/firebase_sync_functions_gateway_test.dart
git commit -m "feat(sync): add Firebase sync gateways"
```

### Task 4: Implement generation repository and safe B3 full push/full pull

**Files:**
- Create: `lib/core/sync/model/sync_generation.dart`
- Create: `lib/core/sync/engine/generation_repository.dart`
- Modify: `lib/core/sync/bootstrap/full_push.dart`
- Modify: `lib/core/sync/bootstrap/full_pull.dart`
- Modify or remove: `lib/core/sync/cloud_progress_gateway.dart`
- Test: `test/core/sync/bootstrap/full_push_test.dart`
- Test: `test/core/sync/bootstrap/full_pull_test.dart`
- Create: `test/core/sync/generation_repository_test.dart`

**Interfaces:**

```dart
enum B3Choice { keepDevice, keepAccount }

class ActiveGeneration {
  const ActiveGeneration({required this.id, required this.preferences});
  final String id;
  final Map<String, Object?> preferences;
}
```

Generation operations must expose: read active generation; detect meaningful cloud data; stage complete local snapshot; activate through `SyncFunctionsGateway`; materialize complete active snapshot; replace local Sync-owned state transactionally.

- [ ] **Step 1: Write B3/bootstrap RED tests**

Required cases:
- no active generation + empty device stages/activates current account preferences;
- active generation + empty local device pulls even when cloud contains only preferences;
- local meaningful + existing generation with no meaningful cloud records auto-Keep-device;
- full push leaves existing active generation untouched if any staging batch fails;
- activation is never called before all staging writes succeed;
- full pull completes all reads/map validation before the first destructive local statement;
- failed read preserves pre-existing local Sync rows;
- successful pull replaces Sync-owned rows, queue state, and `sync_row_meta` in one transaction;
- successful pull preserves an in-progress mock attempt and other intentionally device-local state.

- [ ] **Step 2: Run RED**

```bash
flutter test --no-test-assets test/core/sync/bootstrap/full_push_test.dart test/core/sync/bootstrap/full_pull_test.dart test/core/sync/generation_repository_test.dart
```

- [ ] **Step 3: Implement exact generation paths**

```text
users/<uid>/sync_state/current
users/<uid>/sync_generations/<generationId>
users/<uid>/sync_generations/<generationId>/<collection>/<rowId>
```

Stage metadata: `status: staging`, `schemaVersion: 1`, `createdAt: serverTimestamp`, `createdByDeviceId`, and generation-scoped `preferences`. Use `activeSyncCollections` to build snapshot writes. Full pull materializes every collection plus generation preferences before opening the replacement transaction.

- [ ] **Step 4: Run GREEN**

```bash
flutter test --no-test-assets test/core/sync/bootstrap/full_push_test.dart test/core/sync/bootstrap/full_pull_test.dart test/core/sync/generation_repository_test.dart
```

- [ ] **Step 5: Commit**

```bash
git add lib/core/sync/bootstrap lib/core/sync/cloud_progress_gateway.dart lib/core/sync/engine/generation_repository.dart lib/core/sync/model/sync_generation.dart test/core/sync/bootstrap test/core/sync/generation_repository_test.dart
git commit -m "feat(sync): add generation-safe reconciliation"
```

### Task 5: Make queue coalescing and normal push stale-base safe

**Files:**
- Modify: `lib/core/sync/engine/pending_queue.dart`
- Modify: `lib/core/sync/engine/push_pipeline.dart`
- Test: `test/core/sync/pending_queue_test.dart`
- Test: `test/core/sync/push_pipeline_test.dart`

**Interfaces:**

```dart
Future<void> enqueue({
  required String generationId,
  required String tableType,
  required String rowId,
  required PendingSyncOp op,
  required DateTime? baseUpdatedAt,
  required String mutationId,
  required DateTime queuedAt,
});
```

Repeated edits increment `revision`, keep the original `baseUpdatedAt`, replace operation/mutation identity, and remain generation-scoped.

- [ ] **Step 1: Add RED tests**

Cover:
- repeated edit keeps original base and increments revision;
- same row ID in different generations does not collide;
- null-base create to absent cloud commits;
- non-null-base row whose cloud document is absent does not recreate a garbage-collected deletion;
- newer cloud timestamp wins stale local upsert;
- stale local delete cannot erase newer cloud upsert;
- delete commit is a tombstone, never physical `FirestoreWrite.delete`;
- acknowledgement clears only the revision committed;
- a newer same-device edit that happened in flight remains queued with its base advanced to authoritative server time;
- transient gateway failure increments retry diagnostics and leaves the queue row durable.

- [ ] **Step 2: Run RED**

```bash
flutter test --no-test-assets test/core/sync/pending_queue_test.dart test/core/sync/push_pipeline_test.dart
```

- [ ] **Step 3: Implement push semantics**

Upsert loads the current local row through the registry adapter immediately before commit. Delete writes:

```dart
{
  'deleted': true,
  'updatedAt': FirestoreServerTimestamp.value,
  'originDeviceId': deviceId,
  'mutationId': pending.mutationId,
  'schemaVersion': 1,
}
```

Live rows carry mapped domain payload plus the same metadata with `deleted: false`. `RowStale` must reconcile accepted cloud state locally before clearing/superseding the stale queue lineage.

- [ ] **Step 4: Run GREEN**

```bash
flutter test --no-test-assets test/core/sync/pending_queue_test.dart test/core/sync/push_pipeline_test.dart
```

- [ ] **Step 5: Commit**

```bash
git add lib/core/sync/engine/pending_queue.dart lib/core/sync/engine/push_pipeline.dart test/core/sync/pending_queue_test.dart test/core/sync/push_pipeline_test.dart
git commit -m "feat(sync): protect queued writes from stale bases"
```

### Task 6: Implement listeners, echoes, known absence, debounce, and reconnect flush

**Files:**
- Modify: `lib/core/sync/engine/pull_pipeline.dart`
- Modify: `lib/core/sync/engine/sync_engine.dart`
- Test: `test/core/sync/pull_pipeline_test.dart`
- Test: `test/core/sync/sync_engine_test.dart`

**Interfaces:**

```dart
class PullPipeline {
  Future<void> applySnapshot({
    required String generationId,
    required SyncCollectionAdapter adapter,
    required List<SyncDocument> documents,
    required bool isInitialSnapshot,
  });
}
```

`SyncEngine.start` receives UID, generation ID, and device ID; subscribes to `sync_state/current` and every active collection; schedules ordinary queue flushes with one 5-second debounce timer. `stop` cancels the timer and every subscription before returning.

- [ ] **Step 1: Add RED listener/conflict tests**

Cover matching mutation echo, exact-revision acknowledgement, newer same-device revision preservation, newer remote live-row apply, tombstone apply, known-absence deletion after tombstone garbage collection, legitimate null-base pending create preservation, generation-pointer change ordering, quarantine of old-generation queue on failed replacement, and removal only after successful replacement.

- [ ] **Step 2: Add RED scheduler/reconnect tests**

Using a controllable clock/timer seam or `fakeAsync` equivalent already available through Flutter test:

```dart
engine.notifyLocalMutation();
elapse(const Duration(seconds: 4, milliseconds: 999));
expect(gateway.commitCalls, 0);
elapse(const Duration(milliseconds: 1));
expect(gateway.commitCalls, 1);
```

Also prove multiple mutations inside the window coalesce to one flush, and an active Firestore stream event received after an offline/error state triggers an immediate queued flush as the connectivity-restoration signal. No `connectivity_plus` dependency is added.

- [ ] **Step 3: Run RED**

```bash
flutter test --no-test-assets test/core/sync/pull_pipeline_test.dart test/core/sync/sync_engine_test.dart
```

- [ ] **Step 4: Implement listener/scheduler lifecycle**

The first complete snapshot for each collection performs known-absence reconciliation. A control-document generation change executes `cancel old collection subscriptions -> safe full pull -> start new subscriptions`. Firestore stream recovery is the reconnect signal: when the engine was offline/error and receives healthy data again, request an immediate flush instead of waiting 5 seconds.

- [ ] **Step 5: Run GREEN and commit**

```bash
flutter test --no-test-assets test/core/sync/pull_pipeline_test.dart test/core/sync/sync_engine_test.dart
git add lib/core/sync/engine/pull_pipeline.dart lib/core/sync/engine/sync_engine.dart test/core/sync/pull_pipeline_test.dart test/core/sync/sync_engine_test.dart
git commit -m "feat(sync): converge active generation listeners"
```

### Task 7: Implement three-part eligibility and B3 runtime state machine

**Files:**
- Create: `lib/core/sync/eligibility/sync_claim_gateway.dart`
- Create: `lib/core/sync/eligibility/sync_entitlement.dart`
- Create: `lib/core/sync/runtime/sync_runtime_controller.dart`
- Modify: `lib/core/sync/sync_status.dart`
- Modify: `lib/core/sync/sync_coordinator.dart`
- Test: `test/core/sync/sync_eligibility_test.dart`
- Test: `test/core/sync/sync_runtime_controller_test.dart`

**Interfaces:**

```dart
class SyncEntitlementSnapshot {
  const SyncEntitlementSnapshot({required this.proIsActive});
  final bool proIsActive;
}

abstract interface class SyncClaimGateway {
  Future<bool> refreshHasProClaim();
}

class FirebaseSyncClaimGateway implements SyncClaimGateway {
  @override
  Future<bool> refreshHasProClaim() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return false;
    final token = await user.getIdTokenResult(true);
    return token.claims?['pro'] == true;
  }
}
```

Frozen UI/runtime statuses: `SyncOff`, `SyncActivating`, `SyncReconciliationRequired`, `Syncing`, `SyncUpToDate`, `SyncOffline`, `SyncError`.

- [ ] **Step 1: Add RED state-machine tests**

Required cases:
- anonymous + RevenueCat Pro => `off`;
- named + Free => `off`;
- named + RevenueCat Pro + missing claim => `activating` and zero progress Firestore reads;
- named + RevenueCat Pro + Pro claim => run B3;
- both meaningful => `reconciliationRequired`, engine not started;
- local only => automatic Keep-device;
- empty local + existing generation => automatic Keep-account, including preferences-only generation;
- no generation => stage/activate current device snapshot;
- Firestore transient failure maps to `offline` or `error` while queue remains intact;
- explicit retry re-evaluates claim/B3 or flushes as appropriate;
- eligibility loss cancels listeners/new work;
- restore re-runs B3 and does not blindly resume a prior generation.

- [ ] **Step 2: Run RED**

```bash
flutter test --no-test-assets test/core/sync/sync_eligibility_test.dart test/core/sync/sync_runtime_controller_test.dart
```

- [ ] **Step 3: Implement serialized runtime transitions**

Expose:

```dart
Future<void> updateIdentityAndEntitlement({
  required String? uid,
  required bool isAnonymous,
  required bool revenueCatPro,
});
Future<void> resolveReconciliation(B3Choice choice);
Future<void> forceFlush();
Future<void> quiesce({required bool flush});
```

Serialize transition calls so Auth and entitlement events cannot start two B3 flows. A false refreshed Pro claim emits `SyncActivating`; retries happen on explicit retry or subsequent identity/entitlement events, never an idle polling timer.

- [ ] **Step 4: Run GREEN and commit**

```bash
flutter test --no-test-assets test/core/sync/sync_eligibility_test.dart test/core/sync/sync_runtime_controller_test.dart
git add lib/core/sync/eligibility lib/core/sync/runtime/sync_runtime_controller.dart lib/core/sync/sync_status.dart lib/core/sync/sync_coordinator.dart test/core/sync/sync_eligibility_test.dart test/core/sync/sync_runtime_controller_test.dart
git commit -m "feat(sync): gate runtime on named Pro eligibility"
```

### Task 8: Move cloud lifecycle ownership out of Auth

**Files:**
- Create: `lib/core/sync/runtime/sync_account_transition_gateway.dart`
- Modify: `lib/core/auth/auth_repository.dart`
- Modify: `lib/app/auth_bootstrap.dart`
- Test: `test/core/sync/sync_account_transition_gateway_test.dart`
- Re-run existing focused Auth repository tests.

**Interfaces:**

```dart
class SyncAccountTransitionGateway implements AccountTransitionGateway {
  SyncAccountTransitionGateway(this.runtime);
  final SyncRuntimeController runtime;

  @override
  Future<void> prepareForSignOut() => runtime.quiesce(flush: true);

  @override
  Future<void> prepareForAccountSwitch() => runtime.quiesce(flush: false);

  @override
  Future<void> prepareForDeleteAccount() => runtime.quiesce(flush: false);
}
```

- [ ] **Step 1: Add RED lifecycle tests**

Assert sign-out flush failure propagates and Auth does not continue to its sign-out/wipe sequence; account switch/delete quiesce without flushing; all transition preparations stop listeners/new work first. Add a source/compile contract that `auth_repository.dart` no longer declares `CloudProgressGateway` or `EmptyCloudProgressGateway`.

- [ ] **Step 2: Run RED**

```bash
flutter test --no-test-assets test/core/sync/sync_account_transition_gateway_test.dart test/core/auth/auth_repository_sign_out_test.dart test/core/auth/auth_repository_collision_test.dart test/core/auth/auth_repository_privacy_test.dart
```

- [ ] **Step 3: Implement minimal compatibility cleanup**

Delete only Wave 2D's temporary cloud-progress compatibility declarations from Auth. Ensure Sync cloud meaningful-progress code no longer imports Auth. Extend `authRepositoryOverrides` with an account-transition builder seam and inject `SyncAccountTransitionGateway` for configured Firebase.

- [ ] **Step 4: Run GREEN and commit**

```bash
flutter test --no-test-assets test/core/sync/sync_account_transition_gateway_test.dart test/core/auth/auth_repository_sign_out_test.dart test/core/auth/auth_repository_collision_test.dart test/core/auth/auth_repository_privacy_test.dart
git add lib/core/auth/auth_repository.dart lib/core/sync/cloud_progress_gateway.dart lib/core/sync/runtime/sync_account_transition_gateway.dart lib/app/auth_bootstrap.dart test/core/sync/sync_account_transition_gateway_test.dart
git commit -m "refactor(sync): own cloud lifecycle outside Auth"
```

### Task 9: Wire production providers, startup binding, background flush, and blocking B3 UI

**Files:**
- Modify: `lib/core/sync/providers.dart`
- Modify: `lib/core/sync/sync.dart`
- Create: `lib/app/sync_runtime_bootstrap.dart`
- Modify: `lib/app/bootstrap.dart`
- Modify: `lib/app/app.dart`
- Create: `lib/features/settings/presentation/widgets/sync_reconciliation_gate.dart`
- Modify: `lib/l10n/app_en.arb`
- Test: `test/core/sync/providers_test.dart`
- Create: `test/app/sync_runtime_bootstrap_test.dart`
- Create: `test/features/settings/presentation/sync_reconciliation_gate_test.dart`

**Interfaces:**

```dart
final syncEntitlementProvider = Provider<SyncEntitlementSnapshot>(
  (ref) => const SyncEntitlementSnapshot(proIsActive: false),
);
```

`lib/app/sync_runtime_bootstrap.dart` owns the cross-feature bridge from `entitlementProvider.valueOrNull?.proIsActive ?? false` to this provider. `core/sync` must not import `features/paywall`.

- [ ] **Step 1: Add RED provider/UI tests**

Assert configured Firebase composition uses real gateways/runtime and never defaults to `FakeSyncEngine`; unavailable Firebase stays safely `off`; entitlement/Auth changes reach the runtime; app-background lifecycle forces flush immediately; reconciliation state renders a non-dismissible overlay; only the two frozen choices resolve it; automatic B3 states render no modal.

Freeze English copy:

```text
Title: Choose which progress to keep
Body: Pantas found progress on this device and in your account. Choose one copy to keep before syncing starts.
Buttons: Keep this device / Keep my account
```

- [ ] **Step 2: Run RED**

```bash
flutter test --no-test-assets test/core/sync/providers_test.dart test/app/sync_runtime_bootstrap_test.dart test/features/settings/presentation/sync_reconciliation_gate_test.dart
```

- [ ] **Step 3: Implement startup/runtime binding**

Build real Sync overrides from the live database and Firebase gateways. Attach `ProviderContainer.listen` subscriptions to Auth identity and bridged entitlement. Register a `WidgetsBindingObserver` that requests an immediate best-effort flush on background states. Call the Sync binder only after `bootstrapRevenueCat(container)` so the entitlement source has bootstrapped.

Wrap the existing notification router child in `SyncReconciliationGate`; do not replace router/navigation state.

- [ ] **Step 4: Run GREEN, generate localization, and commit**

```bash
flutter gen-l10n
flutter test --no-test-assets test/core/sync/providers_test.dart test/app/sync_runtime_bootstrap_test.dart test/features/settings/presentation/sync_reconciliation_gate_test.dart
git add lib/core/sync/providers.dart lib/core/sync/sync.dart lib/app/sync_runtime_bootstrap.dart lib/app/bootstrap.dart lib/app/app.dart lib/features/settings/presentation/widgets/sync_reconciliation_gate.dart lib/l10n test/core/sync/providers_test.dart test/app/sync_runtime_bootstrap_test.dart test/features/settings/presentation/sync_reconciliation_gate_test.dart
git commit -m "feat(sync): wire production runtime and B3 gate"
```

### Task 10: Complete 2E-1 verification and hand back a clean branch

**Files:** No new production scope. Repair only defects exposed by these gates and keep repairs within 2E-1 ownership.

- [ ] **Step 1: Re-establish exact base and generated state**

```bash
BASE="$(git merge-base HEAD origin/codex/firebase-runtime-integration)"
test "$BASE" = "$(git rev-parse origin/codex/firebase-runtime-integration)"
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

Expected: all commands exit 0.

- [ ] **Step 2: Run all Sync and directly affected Auth/bootstrap/UI tests**

```bash
flutter test --no-test-assets \
  test/core/sync \
  test/core/auth/auth_repository_collision_test.dart \
  test/core/auth/auth_repository_privacy_test.dart \
  test/core/auth/auth_repository_sign_out_test.dart \
  test/app/auth_bootstrap_test.dart \
  test/app/sync_runtime_bootstrap_test.dart \
  test/features/settings/presentation/sync_reconciliation_gate_test.dart
```

Expected: zero failures and zero load failures.

- [ ] **Step 3: Analyze the changed Dart surface**

```bash
CHANGED_DART="$(git diff --name-only "$BASE"...HEAD -- '*.dart')"
dart analyze $CHANGED_DART
```

Expected: no analyzer errors/warnings introduced by Wave 2E-1.

- [ ] **Step 4: Run non-rewriting canonical format gate**

```bash
dart format --output=none --set-exit-if-changed $CHANGED_DART
```

Expected: zero changed, exit 0. If formatting is required, run `dart format $CHANGED_DART`, inspect for formatting-only changes, commit that repair, then rerun the non-rewriting gate.

- [ ] **Step 5: Run repository hygiene gates**

```bash
git diff --check "$BASE"...HEAD
dart run tool/check_no_ai_attribution.dart
git status --short --untracked-files=all
```

Expected: diff check clean, checker `OK`, final tracked worktree clean.

- [ ] **Step 6: Prove ownership/prohibited-path boundaries**

```bash
if git diff --name-only "$BASE"...HEAD | grep -E '^(functions/|firestore\.rules$)'; then
  echo 'STOP: backend-owned path changed'
  exit 1
fi
```

Also inspect the full path list and stop for content corpus, payment-owned implementation, Android signing/release, Sanity, or other excluded ownership.

- [ ] **Step 7: Final handback**

Report exact starting SHA/final SHA, commits/messages, changed paths, generated-code results, focused test totals, analyzer result, full changed-Dart formatter result, diff-check result, no-AI result, ownership result, final tracked status, and confirmation of no PR/merge/Actions/Firebase/Google/Play/Sanity mutation.

Do not merge or fast-forward integration yourself.
