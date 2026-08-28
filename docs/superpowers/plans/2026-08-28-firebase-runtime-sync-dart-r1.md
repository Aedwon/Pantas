# Firebase Runtime Wave 2E-1 — Dart Sync Runtime Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the placeholder Sync client with a production named-Pro runtime that performs B3 reconciliation, generation-safe full push/pull, durable offline queueing, stale-base conflict protection, tombstone delete convergence, lifecycle quiescence, and app-level reconciliation UI.

**Architecture:** Keep Auth identity-only and evolve the existing `lib/core/sync/` skeleton. Drift stores engine-wide state in `sync_meta`, per-row cloud state in a new `sync_row_meta`, and generation-aware pending mutations in `pending_sync`; Firestore access stays behind Sync-owned gateways; Riverpod/app bootstrap wires Auth + RevenueCat entitlement into a plain Sync runtime controller. Full replacement uses stage/activate generations and download-before-replace, while normal writes use server-ordered LWW with stale-base protection.

**Tech Stack:** Flutter 3.41.9, Dart, Riverpod, Drift/SQLite, `firebase_auth`, `cloud_firestore`, `cloud_functions`, Flutter widget tests.

**Spec:** `docs/superpowers/specs/2026-08-28-firebase-runtime-sync-r1-design.md`

## Global Constraints

- Implementation branch must start from the exact coordinator planning SHA supplied in the worker prompt.
- Anonymous Free and named Free remain local-only.
- Named Pro Sync eligibility requires named Auth identity + RevenueCat Pro + freshly refreshed Firebase ID token claim `pro == true`.
- Auth does not inspect cloud progress or perform B3.
- `/users/{uid}` remains account metadata, not Sync generation storage.
- Both-sides-meaningful B3 blocks normal Sync and offers exactly `Keep this device` and `Keep my account`.
- B3 does not perform record-level merge.
- Keep-this-device stages a fresh generation before backend activation; it never delete-then-uploads the active generation.
- Keep-my-account downloads and validates the complete snapshot before one local replacement transaction.
- `sync_meta` remains engine-wide key/value state.
- New `sync_row_meta` stores per-row accepted cloud timestamps/origin metadata.
- Domain tables do not gain Sync timestamp columns.
- Pending operations carry generation identity, base cloud timestamp, mutation identity, and local revision.
- Deletes use tombstones retained in cloud by the backend contract for 90 days.
- In-progress mock attempts remain device-local; terminal mock attempts sync.
- Review logs, track scope, and custom blueprints are Sync-owned source data in Wave 2E.
- No idle polling timer and no Sync background isolate.
- Pro expiry/eligibility loss quiesces without deleting either side; restoration re-runs B3.
- Ordinary Pro sign-out may abort if the required flush fails; account deletion never flushes pending mutations first.
- Do not modify `firestore.rules` or `functions/**` in 2E-1.
- Do not modify RevenueCat/paywall-owned implementation files; consume the existing entitlement provider only from `lib/app/` wiring.
- Do not modify Android signing/release, content corpus, Sanity, Remote Config, telemetry Auth identity, or payment product behavior.
- Do not deploy Firebase, run GitHub Actions, open a PR, or merge to `main`.
- Use TDD for every behavior change. Keep commits task-sized.

## File Structure and Ownership

### New files

- `lib/core/storage/data/tables/sync_row_meta_table.dart` — structured per-row accepted cloud metadata.
- `lib/core/sync/model/sync_document.dart` — normalized Firestore document/snapshot and row-commit result types.
- `lib/core/sync/model/sync_generation.dart` — generation control/status and B3 choice/result types.
- `lib/core/sync/engine/sync_collection_adapter.dart` — local table adapter contract used by registry/bootstrap/pipelines.
- `lib/core/sync/engine/sync_meaningful_progress.dart` — B3-only syncable meaningful-data detector.
- `lib/core/sync/engine/generation_repository.dart` — active/staging generation reads and client staging writes.
- `lib/core/sync/eligibility/sync_claim_gateway.dart` — Firebase Pro-claim refresh seam and live adapter.
- `lib/core/sync/eligibility/sync_entitlement.dart` — feature-neutral entitlement snapshot seam.
- `lib/core/sync/runtime/sync_runtime_controller.dart` — eligibility, B3, engine start/stop, status orchestration.
- `lib/core/sync/runtime/sync_account_transition_gateway.dart` — concrete `AccountTransitionGateway` implementation.
- `lib/core/sync/firestore/firebase_firestore_gateway.dart` — real Firestore implementation.
- `lib/core/sync/firestore/firebase_sync_functions_gateway.dart` — real `activateSyncGeneration` callable adapter.
- `lib/core/sync/mapping/review_log_mapper.dart`
- `lib/core/sync/mapping/track_scope_mapper.dart`
- `lib/core/sync/mapping/custom_blueprint_mapper.dart`
- `lib/features/settings/presentation/widgets/sync_reconciliation_gate.dart` — app-level blocking B3 UI.
- `lib/app/sync_runtime_bootstrap.dart` — production overrides/listeners/lifecycle binding.
- Focused tests mirroring each new file under `test/core/sync/**`, `test/app/**`, and `test/features/settings/**`.

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
- `lib/core/sync/cloud_progress_gateway.dart`
- `lib/core/sync/providers.dart`
- `lib/core/sync/sync_status.dart`
- `lib/core/sync/sync_coordinator.dart`
- `lib/core/sync/sync.dart`
- existing mapper files where generation metadata or normalized payload shape must be preserved.
- `lib/core/auth/auth_repository.dart` — remove only the temporary Auth-side `CloudProgressGateway` compatibility declaration/classes.
- `lib/app/auth_bootstrap.dart` — inject real Sync `AccountTransitionGateway` without reopening Auth behavior.
- `lib/app/bootstrap.dart` — install Sync overrides and bind runtime after RevenueCat bootstrap.
- `lib/app/app.dart` — wrap app child in reconciliation gate.
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
- Produces pending columns `generationId`, `baseUpdatedAt`, `mutationId`, `revision` used by Tasks 5–8.

- [ ] **Step 1: Write the schema tests first**

```dart
expect(db.schemaVersion, 23);
expect(
  await db.customSelect('PRAGMA table_info(sync_row_meta)').get(),
  isNotEmpty,
);

final pendingColumns = await db
    .customSelect('PRAGMA table_info(pending_sync)')
    .get();
expect(
  pendingColumns.map((r) => r.data['name']),
  containsAll(['generation_id', 'base_updated_at', 'mutation_id', 'revision']),
);
```

Add a migration test that opens a schema-22 database with one legacy pending row, upgrades to 23, and asserts the legacy pending queue is empty while domain rows remain intact. The pre-production placeholder queue is not authoritative cloud state, so clearing legacy queue intent is safer than assigning it an invented generation.

- [ ] **Step 2: Run the tests and prove RED**

Run:

```bash
flutter test --no-test-assets test/core/sync/sync_schema_test.dart test/core/sync/pending_queue_test.dart
```

Expected: failure because schema version 23, `sync_row_meta`, and generation-aware pending fields do not exist.

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

Change the unique index to `(generationId, tableType, rowId)`. Bump `schemaVersion` from 22 to 23. In the `from < 23` migration: create `syncRowMeta`; clear existing `pending_sync`; add the four new columns; drop `pending_sync_table_row_idx`; create `pending_sync_generation_table_row_idx` over the generation-aware identity. Preserve all domain data and existing `sync_meta` rows.

- [ ] **Step 4: Regenerate Drift code and run GREEN**

Run:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test --no-test-assets test/core/sync/sync_schema_test.dart test/core/sync/pending_queue_test.dart
```

Expected: all tests pass.

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
- Modify existing mappers in `lib/core/sync/mapping/` only as required to expose complete payload round-trips.
- Test: `test/core/sync/collection_registry_test.dart`
- Test: `test/core/sync/meaningful_progress_test.dart`
- Test: mapper tests under `test/core/sync/mapping/`.

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

- [ ] **Step 1: Freeze registry expectations in tests**

Assert exact active paths:

```dart
expect(
  activeSyncCollections.map((e) => e.firestorePath).toSet(),
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

Add meaningful-progress tests proving terminal mocks count, in-progress mocks do not count by themselves, account preferences do not create a B3 conflict, and each of review logs/track scope/custom blueprints counts when present.

- [ ] **Step 2: Run RED**

```bash
flutter test --no-test-assets test/core/sync/collection_registry_test.dart test/core/sync/meaningful_progress_test.dart test/core/sync/mapping
```

Expected: missing adapters/paths and current mock semantics fail the new contract.

- [ ] **Step 3: Implement adapters and mappers**

Keep each mapper responsible only for Drift-row ↔ Firestore-domain payload conversion. `SyncCollectionAdapter` owns database access. For compound-key `track_scope`, use a stable row ID formed as:

```dart
String trackScopeDocumentId(String examId, String topicId) =>
    '${Uri.encodeComponent(examId)}--${Uri.encodeComponent(topicId)}';
```

For terminal mocks, `hasMeaningfulData` and `readAll` include only `completed`, `discarded`, and `forfeited`. Do not include an in-progress mock in the Sync snapshot or B3 detector.

- [ ] **Step 4: Run GREEN**

```bash
flutter test --no-test-assets test/core/sync/collection_registry_test.dart test/core/sync/meaningful_progress_test.dart test/core/sync/mapping
```

Expected: pass.

- [ ] **Step 5: Commit**

```bash
git add lib/core/sync/engine lib/core/sync/mapping test/core/sync/collection_registry_test.dart test/core/sync/meaningful_progress_test.dart test/core/sync/mapping
git commit -m "feat(sync): align backed-up collection registry"
```

### Task 3: Replace fake Firestore/Functions seams with production-capable gateways

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

The real transaction must read from server, compare `updatedAt`, write only when bases match, then server-read the document after commit so sign-out flush can acknowledge authoritative server time without waiting indefinitely for a listener echo.

`SyncFunctionsGateway` becomes:

```dart
abstract interface class SyncFunctionsGateway {
  Future<void> activateGeneration({
    required String generationId,
    required String? expectedActiveGenerationId,
  });
}
```

Map backend `failed-precondition` generation conflicts to stable client code `generation-conflict`.

- [ ] **Step 1: Write gateway contract tests**

Cover null-base create, matching-base update, stale-base update, missing-current with non-null base, serverTimestamp normalization, collection/document streams, activation payload, and stable function error mapping.

- [ ] **Step 2: Run RED**

```bash
flutter test --no-test-assets test/core/sync/firestore_gateway_contract_test.dart test/core/sync/firebase_firestore_gateway_test.dart test/core/sync/firebase_sync_functions_gateway_test.dart
```

- [ ] **Step 3: Implement the gateways**

Use `FirebaseFirestore.instance` and `FirebaseFunctions.instanceFor(region: 'asia-southeast1')`. Convert Firestore `Timestamp` recursively at the gateway boundary so the rest of Sync sees `DateTime` values. Keep Firebase SDK types out of adapters and pipelines.

- [ ] **Step 4: Run GREEN**

```bash
flutter test --no-test-assets test/core/sync/firestore_gateway_contract_test.dart test/core/sync/firebase_firestore_gateway_test.dart test/core/sync/firebase_sync_functions_gateway_test.dart
```

- [ ] **Step 5: Commit**

```bash
git add lib/core/sync/firestore lib/core/sync/model test/core/sync/firestore_gateway_contract_test.dart test/core/sync/firebase_firestore_gateway_test.dart test/core/sync/firebase_sync_functions_gateway_test.dart
git commit -m "feat(sync): add Firebase sync gateways"
```

### Task 4: Implement generation repository and safe B3 full push/full pull

**Files:**
- Create: `lib/core/sync/model/sync_generation.dart`
- Create: `lib/core/sync/engine/generation_repository.dart`
- Modify: `lib/core/sync/bootstrap/full_push.dart`
- Modify: `lib/core/sync/bootstrap/full_pull.dart`
- Replace Auth-importing behavior in: `lib/core/sync/cloud_progress_gateway.dart`
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

class GenerationRepository {
  Future<ActiveGeneration?> readActive(String uid);
  Future<bool> hasMeaningfulCloudData(String uid, String generationId);
  Future<String> stageLocalSnapshot({required String uid, required String deviceId});
  Future<void> activate({
    required String generationId,
    required String? expectedActiveGenerationId,
  });
  Future<void> replaceLocalFromActive({required String uid, required String generationId});
}
```

- [ ] **Step 1: Write B3 bootstrap safety tests**

Required tests:
- no active generation + empty device stages/activates current account preferences;
- active generation + empty local device pulls even when cloud has only preferences;
- local meaningful + active generation with no meaningful cloud data auto-stages device;
- full push leaves current generation untouched if staging batch fails;
- activation is not called until every staging batch succeeds;
- full pull performs all reads before the first destructive local statement;
- failed read preserves pre-existing local rows;
- successful pull replaces Sync-owned rows and `sync_row_meta` in one transaction;
- successful pull does not delete an in-progress mock attempt.

- [ ] **Step 2: Run RED**

```bash
flutter test --no-test-assets test/core/sync/bootstrap/full_push_test.dart test/core/sync/bootstrap/full_pull_test.dart test/core/sync/generation_repository_test.dart
```

- [ ] **Step 3: Implement generation paths exactly**

Use:

```text
users/<uid>/sync_state/current
users/<uid>/sync_generations/<generationId>
users/<uid>/sync_generations/<generationId>/<collection>/<rowId>
```

Stage generation metadata with `status: staging`, `schemaVersion: 1`, `createdByDeviceId`, server `createdAt`, and generation-scoped `preferences`. Build all collection writes through `activeSyncCollections`. `replaceLocalFromActive` must materialize every remote collection in memory before opening the replacement transaction.

- [ ] **Step 4: Run GREEN**

```bash
flutter test --no-test-assets test/core/sync/bootstrap/full_push_test.dart test/core/sync/bootstrap/full_pull_test.dart test/core/sync/generation_repository_test.dart
```

- [ ] **Step 5: Commit**

```bash
git add lib/core/sync/bootstrap lib/core/sync/cloud_progress_gateway.dart lib/core/sync/engine/generation_repository.dart lib/core/sync/model/sync_generation.dart test/core/sync/bootstrap test/core/sync/generation_repository_test.dart
git commit -m "feat(sync): add generation-safe reconciliation"
```

### Task 5: Make pending queue and push pipeline stale-base safe

**Files:**
- Modify: `lib/core/sync/engine/pending_queue.dart`
- Modify: `lib/core/sync/engine/push_pipeline.dart`
- Test: `test/core/sync/pending_queue_test.dart`
- Test: `test/core/sync/push_pipeline_test.dart`

**Interfaces:**

`PendingQueue.enqueue` becomes generation-aware:

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

Coalescing increments `revision`, keeps the original `baseUpdatedAt`, replaces `op`/`mutationId`, and does not reset retry diagnostics unless a successful acknowledgement advances the lineage.

- [ ] **Step 1: Add RED tests**

Cover:
- repeated edit keeps original base and increments revision;
- same row in different generations does not collide;
- null-base create to missing cloud commits;
- non-null-base row with now-missing cloud is stale and cannot recreate;
- newer cloud timestamp wins stale local upsert;
- stale local delete cannot erase a newer cloud upsert;
- delete write is a tombstone payload, not `FirestoreWrite.delete`;
- acknowledgement clears only the revision it committed; a newer same-device edit remains queued with authoritative base advanced.

- [ ] **Step 2: Run RED**

```bash
flutter test --no-test-assets test/core/sync/pending_queue_test.dart test/core/sync/push_pipeline_test.dart
```

- [ ] **Step 3: Implement push semantics**

For upsert, load the current local row through the registry adapter immediately before commit. For delete, write:

```dart
{
  'deleted': true,
  'updatedAt': FirestoreServerTimestamp.value,
  'originDeviceId': deviceId,
  'mutationId': pending.mutationId,
  'schemaVersion': 1,
}
```

Live rows use the mapped payload plus the same metadata with `deleted: false`. On `RowStale`, reconcile the authoritative cloud row through the pull apply path and clear/supersede the stale queue lineage only after the local transaction succeeds.

- [ ] **Step 4: Run GREEN**

```bash
flutter test --no-test-assets test/core/sync/pending_queue_test.dart test/core/sync/push_pipeline_test.dart
```

- [ ] **Step 5: Commit**

```bash
git add lib/core/sync/engine/pending_queue.dart lib/core/sync/engine/push_pipeline.dart test/core/sync/pending_queue_test.dart test/core/sync/push_pipeline_test.dart
git commit -m "feat(sync): protect queued writes from stale bases"
```

### Task 6: Implement active-generation listeners, echoes, tombstones, and known absence

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

`SyncEngine.start` takes `uid`, `generationId`, and device ID; it subscribes to the control document and each active generation collection. `stop` cancels every subscription before returning.

- [ ] **Step 1: Add RED tests**

Cover:
- matching `mutationId` echo adopts authoritative timestamp;
- echo clears exact acknowledged revision only;
- echo with newer local revision advances its base instead of dropping it;
- newer remote live row applies domain + `sync_row_meta` atomically;
- tombstone removes domain row and retains advanced row metadata atomically;
- initial complete snapshot removes a known row that is absent after tombstone garbage collection;
- initial snapshot does not delete a genuinely new local row with null base and a pending create;
- generation-pointer change stops old listeners before full pull;
- old-generation pending rows remain quarantined if new-generation pull fails;
- old-generation pending rows are removed only after successful replacement.

- [ ] **Step 2: Run RED**

```bash
flutter test --no-test-assets test/core/sync/pull_pipeline_test.dart test/core/sync/sync_engine_test.dart
```

- [ ] **Step 3: Implement listener lifecycle**

Do not poll. Use Firestore streams supplied by the gateway. The first snapshot for each collection is marked complete and used for known-absence reconciliation. A control-document generation change executes `stop collection listeners -> safe full pull -> start new listeners` in that order.

- [ ] **Step 4: Run GREEN**

```bash
flutter test --no-test-assets test/core/sync/pull_pipeline_test.dart test/core/sync/sync_engine_test.dart
```

- [ ] **Step 5: Commit**

```bash
git add lib/core/sync/engine/pull_pipeline.dart lib/core/sync/engine/sync_engine.dart test/core/sync/pull_pipeline_test.dart test/core/sync/sync_engine_test.dart
git commit -m "feat(sync): converge active generation listeners"
```

### Task 7: Implement three-part eligibility and the B3 runtime state machine

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

Replace obsolete partial-failure escalation states with the frozen surface: `SyncOff`, `SyncActivating`, `SyncReconciliationRequired`, `Syncing`, `SyncUpToDate`, `SyncOffline`, `SyncError`.

- [ ] **Step 1: Add RED state-machine tests**

Required matrix:
- anonymous + Pro => `off`;
- named + Free => `off`;
- named + RevenueCat Pro + missing claim => `activating`, no Firestore data access;
- named + RevenueCat Pro + Pro claim => run B3;
- both meaningful => `reconciliationRequired` and engine not started;
- local only => automatic Keep-device;
- cloud only/empty local with existing generation => automatic Keep-account;
- no generation => stage/activate device snapshot;
- eligibility loss stops new work and listeners;
- restore re-runs B3 instead of resuming old engine blindly.

- [ ] **Step 2: Run RED**

```bash
flutter test --no-test-assets test/core/sync/sync_eligibility_test.dart test/core/sync/sync_runtime_controller_test.dart
```

- [ ] **Step 3: Implement the controller**

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

Serialize transitions so concurrent Auth/entitlement events cannot start two B3 flows. After RevenueCat reports Pro, refresh the claim immediately; if false, emit `SyncActivating` and retry only on entitlement/Auth refresh triggers or explicit retry, not an idle timer.

- [ ] **Step 4: Run GREEN**

```bash
flutter test --no-test-assets test/core/sync/sync_eligibility_test.dart test/core/sync/sync_runtime_controller_test.dart
```

- [ ] **Step 5: Commit**

```bash
git add lib/core/sync/eligibility lib/core/sync/runtime/sync_runtime_controller.dart lib/core/sync/sync_status.dart lib/core/sync/sync_coordinator.dart test/core/sync/sync_eligibility_test.dart test/core/sync/sync_runtime_controller_test.dart
git commit -m "feat(sync): gate runtime on named Pro eligibility"
```

### Task 8: Move cloud progress ownership out of Auth and wire lifecycle preparation

**Files:**
- Create: `lib/core/sync/runtime/sync_account_transition_gateway.dart`
- Modify: `lib/core/auth/auth_repository.dart`
- Modify: `lib/app/auth_bootstrap.dart`
- Test: `test/core/sync/sync_account_transition_gateway_test.dart`
- Modify Auth tests only where compile-time compatibility changes require it; do not alter Wave 2D behavior expectations.

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

Assert sign-out preparation flush failure propagates and therefore Auth sign-out is not reached; account switch/delete never call flush; all three cancel listeners/new Sync work first.

Add a compile contract proving `auth_repository.dart` no longer declares `CloudProgressGateway` or `EmptyCloudProgressGateway`.

- [ ] **Step 2: Run RED**

```bash
flutter test --no-test-assets test/core/sync/sync_account_transition_gateway_test.dart test/core/auth/auth_repository_sign_out_test.dart test/core/auth/auth_repository_collision_test.dart test/core/auth/auth_repository_privacy_test.dart
```

- [ ] **Step 3: Implement minimal Auth compatibility cleanup**

Delete only the temporary compatibility interface/classes from `auth_repository.dart`. Update `cloud_progress_gateway.dart` into a Sync-native detector/repository helper or remove it if Task 4 fully superseded it. Extend `authRepositoryOverrides` with an `AccountTransitionGatewayBuilder` seam and inject `SyncAccountTransitionGateway(ref.watch(syncRuntimeControllerProvider))` when Firebase is configured.

- [ ] **Step 4: Run GREEN**

```bash
flutter test --no-test-assets test/core/sync/sync_account_transition_gateway_test.dart test/core/auth/auth_repository_sign_out_test.dart test/core/auth/auth_repository_collision_test.dart test/core/auth/auth_repository_privacy_test.dart
```

- [ ] **Step 5: Commit**

```bash
git add lib/core/auth/auth_repository.dart lib/core/sync/cloud_progress_gateway.dart lib/core/sync/runtime/sync_account_transition_gateway.dart lib/app/auth_bootstrap.dart test/core/sync/sync_account_transition_gateway_test.dart test/core/auth
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

Provide defaults that are safe/inert when Firebase is unavailable, but never make shipping configured Firebase default to `FakeSyncEngine`.

Use a feature-neutral provider in core:

```dart
final syncEntitlementProvider = Provider<SyncEntitlementSnapshot>(
  (ref) => const SyncEntitlementSnapshot(proIsActive: false),
);
```

In `lib/app/sync_runtime_bootstrap.dart`, create overrides using the real database/gateways/controller and bridge `entitlementProvider.valueOrNull?.proIsActive ?? false` into `syncEntitlementProvider`. Attach `ProviderContainer.listen` subscriptions for `authStateProvider` and entitlement changes. Add a `WidgetsBindingObserver` whose `didChangeAppLifecycleState(AppLifecycleState.paused|inactive|detached)` calls `forceFlush()` best-effort only when Sync is eligible; do not add a timer.

- [ ] **Step 1: Add RED provider/UI tests**

Assert:
- configured override returns real runtime/gateways, not `FakeSyncEngine`;
- unavailable Firebase remains safe/off;
- RevenueCat value bridges without importing paywall from `core/sync`;
- auth + entitlement changes reach runtime controller;
- background lifecycle requests a flush;
- `SyncReconciliationRequired` renders a non-dismissible overlay;
- only `Keep this device` and `Keep my account` resolve it;
- automatic B3 states show no modal.

Use copy:

```text
Title: Choose which progress to keep
Body: Pantas found progress on this device and in your account. Choose one copy to keep before syncing starts.
Buttons: Keep this device / Keep my account
```

- [ ] **Step 2: Run RED**

```bash
flutter test --no-test-assets test/core/sync/providers_test.dart test/app/sync_runtime_bootstrap_test.dart test/features/settings/presentation/sync_reconciliation_gate_test.dart
```

- [ ] **Step 3: Implement composition**

Call Sync runtime bootstrap only after `bootstrapRevenueCat(container)` so the first entitlement value is available. Wrap the existing `NotificationTapRouter` child in `SyncReconciliationGate` inside `App.builder`; do not replace router/navigation state.

- [ ] **Step 4: Run GREEN and regenerate localization output**

```bash
flutter gen-l10n
flutter test --no-test-assets test/core/sync/providers_test.dart test/app/sync_runtime_bootstrap_test.dart test/features/settings/presentation/sync_reconciliation_gate_test.dart
```

Expected: pass.

- [ ] **Step 5: Commit**

```bash
git add lib/core/sync/providers.dart lib/core/sync/sync.dart lib/app/sync_runtime_bootstrap.dart lib/app/bootstrap.dart lib/app/app.dart lib/features/settings/presentation/widgets/sync_reconciliation_gate.dart lib/l10n test/core/sync/providers_test.dart test/app/sync_runtime_bootstrap_test.dart test/features/settings/presentation/sync_reconciliation_gate_test.dart
git commit -m "feat(sync): wire production runtime and B3 gate"
```

### Task 10: Run complete 2E-1 verification and produce a clean handback

**Files:** No new production scope. Repair only defects exposed by these gates and keep any repair within 2E-1 ownership.

- [ ] **Step 1: Regenerate required code**

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

Expected: exit 0.

- [ ] **Step 2: Run all Sync + directly affected Auth/bootstrap/UI tests**

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

Expected: 0 failures, 0 skipped load failures.

- [ ] **Step 3: Analyze exactly the changed Dart surface**

```bash
CHANGED_DART=$(git diff --name-only <WORKER_BASE_SHA>...HEAD -- '*.dart')
dart analyze $CHANGED_DART
```

Expected: no errors or warnings introduced by Wave 2E-1. Replace `<WORKER_BASE_SHA>` with the exact base SHA in the worker prompt before running; do not guess it.

- [ ] **Step 4: Run non-rewriting canonical format gate**

```bash
dart format --output=none --set-exit-if-changed $CHANGED_DART
```

Expected: `0 changed`, exit 0. If formatter reports changes, run `dart format $CHANGED_DART`, inspect the diff, commit formatting-only repair, then rerun the non-rewriting gate.

- [ ] **Step 5: Run repository hygiene gates**

```bash
git diff --check <WORKER_BASE_SHA>...HEAD
dart run tool/check_no_ai_attribution.dart
git status --short --untracked-files=all
```

Expected: diff check clean, checker `OK`, tracked worktree clean after any permitted generated dependency metadata is removed/restored to repository convention.

- [ ] **Step 6: Prove ownership boundary**

```bash
git diff --name-only <WORKER_BASE_SHA>...HEAD | grep -E '^(functions/|firestore\.rules$)' && exit 1 || true
```

Expected: no backend/rules paths.

Also inspect for prohibited content/payment/release paths and stop if any appear.

- [ ] **Step 7: Final handback**

Report:
- exact starting SHA and final SHA;
- commit list/messages;
- changed-path list;
- generated-code commands/results;
- focused test totals;
- analyzer result;
- complete changed-Dart formatter result;
- `git diff --check` result;
- no-AI result;
- ownership/prohibited-path result;
- final tracked status;
- confirmation that no PR/merge/Actions/Firebase/Google/Play/Sanity mutation occurred.

Do not merge or fast-forward integration yourself.
