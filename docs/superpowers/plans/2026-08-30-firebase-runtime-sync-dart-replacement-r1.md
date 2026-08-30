# Wave 2E-1 Firebase Runtime Sync Dart Replacement Implementation Plan

> **For Codex:** REQUIRED: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement the approved Wave 2E-1 Dart runtime Sync design across all ten approved mutation sources with transactionally captured causal provenance, UID/generation boundary safety, B3 epoch protection, revision-safe promotion/acknowledgement, stale-base conflict handling, and Dart-owned custom-track authority, without changing the already-certified backend/rules line.

**Architecture:** Domain/storage repositories report only that a syncable logical row changed. A Sync-owned local mutation recorder writes that fact into a durable `sync_local_mutations` journal in the same Drift transaction as the authoritative user-data mutation and advances `localMutationEpoch`; when a stable active UID/generation exists, it also freezes the exact accepted causal row state (`knownAbsent` or `knownVersion`) observed at mutation time, otherwise it records `unbound`. A separate promoter converts only eligible, correctly bound journal revisions into the generation-scoped `pending_sync` outbox without rereading a newer `sync_row_meta` as historical truth. Push/pull/B3 operations use compare-and-set revision/epoch guards. Custom-track identity and scope are authoritative in `AppDatabase`; the content database is an idempotently recoverable projection.

**Tech Stack:** Flutter 3.41.9, Dart, Riverpod, Drift/SQLite, `firebase_auth`, `cloud_firestore`, `cloud_functions`, Flutter tests, `build_runner`.

**Frozen implementation base:** `02cb557a343130ee1ac4eaf818451c790ae55ef3`

**Approved amendment:** `docs/superpowers/specs/2026-08-29-firebase-runtime-sync-dart-amendment-1.md` at `a8e8e87785f4d169501928841dc092bcc39e8352`

**Base design:** `docs/superpowers/specs/2026-08-28-firebase-runtime-sync-r1-design.md`

**Supersedes for execution:** `docs/superpowers/plans/2026-08-28-firebase-runtime-sync-dart-r1.md`

---

## Execution gate and immutable constraints

- Do not execute the superseded `2026-08-28-firebase-runtime-sync-dart-r1.md` plan.
- This replacement plan becomes executable only after the coordinator/user explicitly approves it.
- Start implementation from a branch/worktree whose ancestry contains this approved plan but whose Dart source still matches frozen base `02cb557a343130ee1ac4eaf818451c790ae55ef3` before Wave 2E-1 source changes.
- At implementation start, independently verify the frozen base and approved-plan ancestry. If either differs from the coordinator prompt, stop and report rather than silently rebasing the contract.
- Do not modify `firestore.rules`, `firestore.indexes.json`, or `functions/**`.
- Do not deploy Firebase, invoke GitHub Actions, open/merge a PR, or fast-forward an integration branch unless the coordinator separately instructs it.
- Do not modify RevenueCat/payment-owned implementation, Android signing/release infrastructure, lesson/question/illustration corpora, Sanity, Remote Config/force-update, or telemetry Auth identity.
- Keep anonymous Free and named Free local-only. Named Pro Sync eligibility still requires named Auth + RevenueCat Pro + freshly refreshed Firebase token claim `pro == true`.
- Auth remains identity/account-lifecycle ownership only. B3 and cloud-progress decisions remain Sync-owned.
- B3 remains whole-copy reconciliation only: exactly `Keep this device` or `Keep my account`; no record-level merge.
- In-progress mock attempts remain device-local. Only terminal mock attempts sync.
- Ordinary incremental queue flush debounce remains exactly 5 seconds; app background, explicit retry, and Firestore reconnect may force an immediate flush.
- Pro expiry/quiescence must not discard local data or journal facts. Restore reruns B3.
- Use TDD for every behavior change. Keep each task boundary compiling and generated Drift state reproducible.

## Frozen producer map — no ad-hoc discovery during implementation

The ten approved logical mutation sources and their concrete frozen-base producer seams are:

1. **`quiz_attempts`** — `lib/core/storage/data/repos/attempts_repository.dart`: `AttemptsRepository.save`; `tagItem` already funnels through `save`. Sync-internal `markSynced`/`markFailed` must not create local mutation facts.
2. **`assessments`** — `lib/core/storage/data/repos/assessment_repository.dart`: `AssessmentRepository.saveResult`.
3. **`fsrs_cards`** — `lib/core/storage/data/repos/review_state_repository.dart`: `ReviewStateRepository.upsert`. The local table is `review_state_local`; `markClean` is Sync-internal and must not journal.
4. **`lesson_progress`** — `lib/core/storage/data/repos/lesson_progress_repository.dart`: `LessonProgressRepository.markRead`.
5. **`lesson_bookmarks`** — `lib/core/storage/data/repos/lesson_bookmarks_repository.dart`: `mark`, `unmark`, `unmarkAll`, `reorder`, `clearCustomOrder`. Deletes and bulk operations require journal facts in the same transaction as the authoritative change.
6. **`question_flags`** — `lib/core/storage/data/repos/question_flags_repository.dart`: `flag`, `unflag`.
7. **`mock_exam_attempts`** — `lib/features/mock_exam/data/mock_attempt_repo.dart`: `discard` and terminal `submit` are mutation boundaries. `insertStart` and `flushProgress` remain device-local and do not journal merely because the row is persisted.
8. **`review_logs`** — `lib/core/storage/data/repos/review_log_repository.dart`: append-only `insert`.
9. **`track_scope`** — `lib/core/storage/data/repos/custom_track_repository.dart`: custom-track create/rename/scope/delete authority must move to `AppDatabase`; scope changes emit typed `track_scope` journal rows. Existing `setExcluded` is a producer seam and must become atomic with journal/epoch state.
10. **`custom_blueprints`** — `lib/features/mock_exam/data/custom_blueprint_repository.dart`: `CustomBlueprintRepository.save`.

`study_plan` remains inactive. Account preferences remain generation/B3 metadata as approved by the base design; they are not an eleventh local-mutation-journal source in this amendment.

## Causal invariants that every task must preserve

- `unbound`, `knownAbsent`, and `knownVersion` are distinct structured states. A null timestamp never means both unbound and known-absent.
- A stable active local mutation freezes the accepted `sync_row_meta` state in the same mutation transaction.
- Promotion never substitutes a later `sync_row_meta` version for the frozen journal causal token.
- A journal event with causal UID/generation provenance may be incrementally promoted only if that provenance exactly matches the active UID/generation.
- `unbound` work and prior-UID/prior-generation work are resolved only by B3/generation reconciliation or an acknowledgement that proves the work was represented; they are never silently rebound.
- Journal promotion acknowledgements are conditional on the exact journal revision observed.
- Outbox success/failure acknowledgements are conditional on the exact outbox revision **and** mutation ID observed.
- The push flush loop is serialized.
- `localMutationEpoch` is an engine-wide monotonic B3 guard. Every recorded authoritative syncable logical-row mutation advances it in the same transaction as the domain mutation/journal update. Bulk user actions may advance it multiple times, but every advancement and all corresponding row/journal changes must commit atomically.
- Remote/cloud application bypasses local-mutation recording. Applying accepted cloud state updates domain state and `sync_row_meta`, not a new local user mutation.
- Sync cannot report `upToDate` while relevant journal work, active outbox work, B3 reconciliation, or custom-track projection recovery remains unsettled.

---

### Task 0: Establish the executable worktree and contract guards

**Files:** No production changes.

- [ ] **Step 1: Create/enter an isolated implementation worktree**

Use the coordinator-provided implementation branch/worktree. If one is not already created, use the repository's established worktree workflow rather than implementing on the docs/amendment branch.

- [ ] **Step 2: Verify ancestry and frozen source base**

```bash
git status --short --branch --untracked-files=all
git rev-parse HEAD
git merge-base HEAD 02cb557a343130ee1ac4eaf818451c790ae55ef3
git log --oneline --decorate -8
```

Require the frozen implementation base to be in ancestry and require the approved amendment/plan commits identified by the coordinator. Source changes relative to `02cb557a...` must still be docs-only before implementation begins.

- [ ] **Step 3: Verify current Drift version instead of hard-coding it**

```bash
grep -n "schemaVersion" lib/core/storage/data/app_database.dart
```

At planning time the frozen base reports schema version 22, but the implementation must read the actual checked-out value and use the **next valid version**. Do not mechanically assume 23 if the coordinator has supplied a newer code base.

- [ ] **Step 4: Run baseline focused tests before source modification**

```bash
flutter pub get
flutter test --no-test-assets test/core/sync
```

If the existing baseline is not green, classify the pre-existing failure before changing source.

---

### Task 1: Land the complete compatible Drift state transition in one compilable checkpoint

**Files:**
- Create: `lib/core/storage/data/tables/sync_row_meta_table.dart`
- Create: `lib/core/storage/data/tables/sync_local_mutations_table.dart`
- Create: `lib/core/storage/data/tables/custom_track_meta_local_table.dart`
- Modify: `lib/core/storage/data/tables/pending_sync_table.dart`
- Modify: `lib/core/storage/data/app_database.dart`
- Generated: `lib/core/storage/data/app_database.g.dart`
- Create/modify: `test/core/sync/sync_schema_test.dart`
- Modify: `test/core/sync/pending_queue_test.dart`

**Required structured state:**

`sync_row_meta`, keyed by `(collection,rowId)`, stores the latest accepted cloud row state. It must represent both accepted live version and known absence/tombstone knowledge as required by the base design; do not overload nullable timestamps to represent state ambiguously.

`sync_local_mutations`, keyed logically by `(collection,rowId)`, stores at minimum:
- collection and row ID;
- `upsert`/`delete` operation;
- local revision;
- mutation epoch/ordering value;
- nullable causal UID;
- nullable causal generation ID;
- explicit causal base state: `unbound`, `knownAbsent`, `knownVersion`;
- nullable `baseUpdatedAt`, present only for `knownVersion`;
- durable ordering/diagnostic timestamps as needed.

`pending_sync`, keyed logically by `(uid,generationId,collection,rowId)`, stores at minimum:
- UID and generation ID;
- collection/table type and row ID;
- operation;
- explicit base-state information distinguishing known absence from known version;
- nullable base timestamp only for known-version;
- mutation ID;
- revision;
- queued time and retry/error bookkeeping.

`custom_track_meta_local` stores authoritative custom-track identity metadata, at minimum stable `examId` and `name`, with no Firestore/cloud timestamp fields.

`sync_meta` retains engine-wide state and must support `localMutationEpoch` plus the custom-track projection-recovery marker without turning either into domain columns.

- [ ] **Step 1: Write RED schema/migration tests first**

Cover:
- all four structured Sync tables/changes exist after migration;
- the three causal base states round-trip distinctly;
- domain tables do not acquire cloud timestamps, mutation IDs, UID, or generation fields;
- existing domain data and `sync_meta.deviceId` survive migration;
- legacy placeholder `pending_sync` rows are not mistaken for active-generation outbox rows. Preserve their user-change fact by migrating/coalescing them into `sync_local_mutations` as `unbound` where the legacy row is structurally valid, then rebuild/clear the old outbox representation;
- custom-track authority table is empty on migration unless existing app-authority data can be migrated deterministically; do not scrape content DB during the Drift schema migration itself;
- generated database opens from the previous schema version.

- [ ] **Step 2: Run RED**

```bash
flutter test --no-test-assets test/core/sync/sync_schema_test.dart test/core/sync/pending_queue_test.dart
```

- [ ] **Step 3: Implement table definitions and one coherent migration**

Do not create required generated fields in one commit and defer compatible callers to a later non-compiling commit. The schema/API transition must leave the tree compiling at this task boundary.

- [ ] **Step 4: Regenerate and run GREEN**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test --no-test-assets test/core/sync/sync_schema_test.dart test/core/sync/pending_queue_test.dart
```

- [ ] **Step 5: Commit**

```bash
git add lib/core/storage/data/tables lib/core/storage/data/app_database.dart lib/core/storage/data/app_database.g.dart test/core/sync/sync_schema_test.dart test/core/sync/pending_queue_test.dart
git commit -m "feat(sync): add causal mutation journal state"
```

---

### Task 2: Add Sync-owned mutation context, journal recorder, and epoch CAS primitives

**Files:**
- Create: `lib/core/sync/model/sync_causal_base.dart`
- Create: `lib/core/sync/engine/local_sync_mutation_recorder.dart`
- Create: `lib/core/sync/engine/sync_active_context_store.dart`
- Create or modify: `lib/core/sync/engine/sync_row_meta_repository.dart`
- Create: `test/core/sync/local_sync_mutation_recorder_test.dart`
- Create: `test/core/sync/sync_active_context_store_test.dart`

**Interface shape:** Keep feature/domain callers cloud-neutral. A caller may identify only logical Sync rows and operations; it must never pass UID, generation ID, cloud timestamps, base state, or mutation ID.

An acceptable shape is a recorder-owned transaction API or a `recordWithinTransaction(...)` API used inside the repository's Drift transaction. Whichever form is chosen, tests must prove the domain mutation, journal mutation, and epoch increment are one transaction.

- [ ] **Step 1: Write RED recorder tests**

Required cases:
- no stable active context → journal `unbound`, no causal UID/generation/base timestamp;
- stable active context + accepted row known absent → `knownAbsent` with exact UID/generation;
- stable active context + accepted version V1 → `knownVersion(V1)` with exact UID/generation;
- context becomes unstable during transaction → domain mutation succeeds but journal records `unbound`, never fabricated V1/current metadata;
- repeated local edit of same `(collection,rowId)` advances journal revision and epoch;
- a newer edit after `sync_row_meta` advances to V2 captures V2, while the older journal revision observed before that remains V1 for any in-flight promoter;
- transaction rollback rolls back domain/journal/epoch together;
- remote apply APIs do not call the recorder.

- [ ] **Step 2: Run RED**

```bash
flutter test --no-test-assets test/core/sync/local_sync_mutation_recorder_test.dart test/core/sync/sync_active_context_store_test.dart
```

- [ ] **Step 3: Implement Sync-owned active-context validation**

The runtime may publish stable active UID/generation state into a Sync-owned context store, but the recorder must validate it transactionally before binding causal provenance. Do not make feature repositories inspect Auth/RevenueCat/B3 state directly.

- [ ] **Step 4: Run GREEN and commit**

```bash
flutter test --no-test-assets test/core/sync/local_sync_mutation_recorder_test.dart test/core/sync/sync_active_context_store_test.dart
git add lib/core/sync/model/sync_causal_base.dart lib/core/sync/engine/local_sync_mutation_recorder.dart lib/core/sync/engine/sync_active_context_store.dart lib/core/sync/engine/sync_row_meta_repository.dart test/core/sync/local_sync_mutation_recorder_test.dart test/core/sync/sync_active_context_store_test.dart
git commit -m "feat(sync): capture local mutation provenance"
```

---

### Task 3: Instrument the six AppDatabase mutable producer repositories atomically

**Files:**
- Modify: `lib/core/storage/data/repos/attempts_repository.dart`
- Modify: `lib/core/storage/data/repos/assessment_repository.dart`
- Modify: `lib/core/storage/data/repos/review_state_repository.dart`
- Modify: `lib/core/storage/data/repos/lesson_progress_repository.dart`
- Modify: `lib/core/storage/data/repos/lesson_bookmarks_repository.dart`
- Modify: `lib/core/storage/data/repos/question_flags_repository.dart`
- Create/modify focused tests under `test/core/storage/data/repos/` or `test/core/sync/producers/` following existing test layout.

- [ ] **Step 1: Write RED producer tests**

Prove exact journal coverage:
- `AttemptsRepository.save` → `quiz_attempts`; `tagItem` causes one logical resulting mutation via `save`; `markSynced`/`markFailed` do not journal.
- `AssessmentRepository.saveResult` → `assessments`.
- `ReviewStateRepository.upsert` → `fsrs_cards`; `markClean` does not journal.
- `LessonProgressRepository.markRead` → `lesson_progress`.
- bookmark `mark`, `unmark`, `unmarkAll`, `reorder`, `clearCustomOrder` record every logical affected row, including delete tombstones before rows disappear.
- question `flag` and `unflag` record upsert/delete respectively.
- every producer keeps domain data + journal + epoch atomic.
- feature/storage code still passes no UID/generation/cloud timestamp/mutation ID.

- [ ] **Step 2: Run RED**

Run only the new/affected producer tests first.

- [ ] **Step 3: Implement minimal repository instrumentation**

Inject/use the narrow Sync mutation recorder. Preserve existing public domain method signatures unless a constructor dependency is required; if constructors change, update composition/tests in the same checkpoint so the tree compiles.

- [ ] **Step 4: Run GREEN plus directly affected existing tests**

```bash
flutter test --no-test-assets test/core/storage/data/repos test/core/sync/producers
```

Adjust the command to actual test directories if the repository groups these tests differently; list exact selected files in the handback.

- [ ] **Step 5: Commit**

```bash
git add lib/core/storage/data/repos test/core/storage/data/repos test/core/sync/producers
git commit -m "feat(sync): journal core local mutations"
```

---

### Task 4: Instrument review logs, terminal mock attempts, and custom blueprints

**Files:**
- Modify: `lib/core/storage/data/repos/review_log_repository.dart`
- Modify: `lib/features/mock_exam/data/mock_attempt_repo.dart`
- Modify: `lib/features/mock_exam/data/custom_blueprint_repository.dart`
- Create/modify focused tests for these repositories.

- [ ] **Step 1: Write RED tests**

Cover:
- every `ReviewLogRepository.insert` produces one append-only `review_logs` journal fact;
- mock `insertStart` and `flushProgress` produce **no** Sync journal fact;
- `discard` journals the terminal mock row;
- `submit` journals only when the submitted status is a terminal syncable status and captures the final row state;
- custom blueprint `save` journals `custom_blueprints` atomically with the authoritative upsert;
- repeated save advances revision without losing the original observed causal base for the revision an in-flight promoter already drained.

- [ ] **Step 2: Run RED**

Run the exact repository tests.

- [ ] **Step 3: Implement and run GREEN**

- [ ] **Step 4: Commit**

```bash
git add lib/core/storage/data/repos/review_log_repository.dart lib/features/mock_exam/data/mock_attempt_repo.dart lib/features/mock_exam/data/custom_blueprint_repository.dart test
git commit -m "feat(sync): journal remaining local producers"
```

---

### Task 5: Correct custom-track authority and build recoverable content projection

**Files:**
- Modify: `lib/core/storage/data/repos/custom_track_repository.dart`
- Create: `lib/core/sync/custom_track/custom_track_projection.dart`
- Create or modify: `lib/core/sync/mapping/track_scope_mapper.dart`
- Modify as needed: current content-database custom-track write seam used by `CustomTrackRepository`
- Create: `test/core/sync/custom_track_authority_test.dart`
- Create: `test/core/sync/custom_track_projection_test.dart`
- Create/modify: repository tests for custom-track create/rename/scope/delete.

**Authority rule:** `AppDatabase.custom_track_meta_local` + authoritative `track_scope` rows are the durable user-data source. The content-database custom-track row is only a projection.

**Typed cloud representation in the existing `track_scope` logical collection:**

Metadata payload conceptually carries `kind: custom_track`, `examId`, and `name`. Scope payload carries `kind: scope`, `examId`, and `topicId`. Both use the standard Wave 2E envelope. Document IDs must be deterministic and collision-safe; implement an encoding helper and round-trip/non-collision tests rather than relying on raw delimiter concatenation.

- [ ] **Step 1: Write RED authority/projection tests**

Required cases:
- create commits metadata + initial authoritative scope + journal facts + epoch advancement + projection-required marker before content projection;
- rename updates authoritative metadata and journals the typed metadata logical row;
- inclusion/exclusion changes update authoritative scope and journal only affected typed scope rows;
- delete journals typed metadata/scope deletes before authoritative rows disappear;
- a multi-row custom-track user action cannot partially commit authority/journal state;
- projection failure leaves authoritative AppDatabase state intact, marker set, and retryable;
- retry idempotently rebuilds projection and clears marker only after success;
- deleting/wiping the content projection and rebuilding from AppDatabase restores the same custom track name/identity/scope;
- content projection is never read as the canonical source for full push.

- [ ] **Step 2: Run RED**

```bash
flutter test --no-test-assets test/core/sync/custom_track_authority_test.dart test/core/sync/custom_track_projection_test.dart
```

- [ ] **Step 3: Implement authority-first operations**

For every custom-track state change:
1. one AppDatabase transaction updates authoritative rows, journal entries, epoch, and projection-required marker;
2. rebuild/update the content projection;
3. clear the marker only after projection succeeds.

Add missing rename/delete repository API only as needed by existing/domain flows and tests; do not move cloud concepts into domain-facing method parameters.

- [ ] **Step 4: Run GREEN and commit**

```bash
flutter test --no-test-assets test/core/sync/custom_track_authority_test.dart test/core/sync/custom_track_projection_test.dart
git add lib/core/storage/data/repos/custom_track_repository.dart lib/core/sync/custom_track lib/core/sync/mapping/track_scope_mapper.dart test/core/sync/custom_track_authority_test.dart test/core/sync/custom_track_projection_test.dart
git commit -m "feat(sync): make custom tracks app-authoritative"
```

---

### Task 6: Complete the ten-source registry, adapters, mappings, and meaningful-data contract

**Files:**
- Create/modify: `lib/core/sync/engine/sync_collection_adapter.dart`
- Modify: `lib/core/sync/engine/collection_registry.dart`
- Create/modify mappers under `lib/core/sync/mapping/`, including `review_log_mapper.dart`, `track_scope_mapper.dart`, `custom_blueprint_mapper.dart`
- Create/modify: `lib/core/sync/engine/sync_meaningful_progress.dart`
- Test: `test/core/sync/collection_registry_test.dart`
- Test: `test/core/sync/meaningful_progress_test.dart`
- Test: mapper tests under `test/core/sync/mapping/`

- [ ] **Step 1: Write RED registry tests**

Require exactly these ten active Sync logical collections:

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

Keep `study_plan` inactive. Preferences remain generation metadata, not an active row collection for mutation journaling.

- [ ] **Step 2: Freeze adapter semantics**

- terminal mock snapshot/meaningful-data excludes in-progress rows;
- `track_scope` adapter handles both typed custom-track metadata rows and typed scope rows from AppDatabase authority;
- remote apply writes accepted domain state directly without invoking local mutation recording;
- delete/tombstone mapping round-trips every collection;
- all document ID helpers round-trip and do not collide for actual identifier characters.

- [ ] **Step 3: Run RED**

```bash
flutter test --no-test-assets test/core/sync/collection_registry_test.dart test/core/sync/meaningful_progress_test.dart test/core/sync/mapping
```

- [ ] **Step 4: Implement, run GREEN, commit**

```bash
flutter test --no-test-assets test/core/sync/collection_registry_test.dart test/core/sync/meaningful_progress_test.dart test/core/sync/mapping
git add lib/core/sync/engine lib/core/sync/mapping test/core/sync
git commit -m "feat(sync): complete sync source registry"
```

---

### Task 7: Add production Firestore/Functions gateways and normalized conditional-commit results

**Files:**
- Create/modify: `lib/core/sync/model/sync_document.dart`
- Modify: `lib/core/sync/firestore/firestore_gateway.dart`
- Create/modify: `lib/core/sync/firestore/firebase_firestore_gateway.dart`
- Modify: `lib/core/sync/firestore/functions_gateway.dart`
- Create/modify: `lib/core/sync/firestore/firebase_sync_functions_gateway.dart`
- Test: `test/core/sync/firestore_gateway_contract_test.dart`
- Test: `test/core/sync/firebase_firestore_gateway_test.dart`
- Test: `test/core/sync/firebase_sync_functions_gateway_test.dart`

This task carries forward the unchanged gateway design from the base plan. Normalize Firestore `Timestamp` at the gateway boundary. Conditional row commits return authoritative server state on success and current state on stale-base rejection. Keep Functions region `asia-southeast1` and the certified `activateSyncGeneration` contract.

- [ ] **Step 1: Write/run RED gateway contract tests**

Cover known-absent create, known-version matching update, stale update/delete, missing-current with known version, server timestamp normalization, generation activation, and mapping backend generation conflict to stable client code `generation-conflict`.

- [ ] **Step 2: Implement and run GREEN**

```bash
flutter test --no-test-assets test/core/sync/firestore_gateway_contract_test.dart test/core/sync/firebase_firestore_gateway_test.dart test/core/sync/firebase_sync_functions_gateway_test.dart
```

- [ ] **Step 3: Commit**

```bash
git add lib/core/sync/firestore lib/core/sync/model/sync_document.dart test/core/sync
git commit -m "feat(sync): add Firebase sync gateways"
```

---

### Task 8: Implement revision-safe journal promotion and generation-scoped outbox

**Files:**
- Create: `lib/core/sync/engine/sync_outbox_promoter.dart`
- Modify: `lib/core/sync/engine/pending_queue.dart`
- Modify as needed: `lib/core/sync/engine/sync_row_meta_repository.dart`
- Test: `test/core/sync/sync_outbox_promoter_test.dart`
- Test: `test/core/sync/pending_queue_test.dart`

- [ ] **Step 1: Write RED promotion tests**

Required cases:
- stable bound `knownAbsent` journal event promotes to the matching UID/generation with a fresh mutation ID;
- stable bound `knownVersion(V1)` promotes with **V1** exactly;
- promoter reads journal V1, remote apply advances `sync_row_meta` to V2 before promotion write → promoted outbox still carries V1;
- `unbound` event never promotes incrementally even if `sync_row_meta` later contains V2;
- event bound to old UID or old generation never retargets to the current context;
- promoter observes journal revision N, local edit advances it to N+1 before acknowledgement → N+1 remains journaled;
- repeated outbox enqueue advances outbox revision and mutation ID;
- same logical row under different UID/generation does not collide.

- [ ] **Step 2: Write RED acknowledgement tests**

`PendingQueue.markSuccess` and `markFailure` must accept drained identities carrying row ID plus observed revision/mutation ID, and may only modify the still-matching row. An older in-flight result cannot delete or mutate a newer queued revision.

- [ ] **Step 3: Run RED**

```bash
flutter test --no-test-assets test/core/sync/sync_outbox_promoter_test.dart test/core/sync/pending_queue_test.dart
```

- [ ] **Step 4: Implement promotion without late metadata substitution**

Do not call `sync_row_meta` to manufacture a causal base during promotion. It may be consulted only for unrelated current-state bookkeeping; historical base comes exclusively from the journal revision being promoted.

- [ ] **Step 5: Run GREEN and commit**

```bash
flutter test --no-test-assets test/core/sync/sync_outbox_promoter_test.dart test/core/sync/pending_queue_test.dart
git add lib/core/sync/engine/sync_outbox_promoter.dart lib/core/sync/engine/pending_queue.dart lib/core/sync/engine/sync_row_meta_repository.dart test/core/sync/sync_outbox_promoter_test.dart test/core/sync/pending_queue_test.dart
git commit -m "feat(sync): promote causal mutations safely"
```

---

### Task 9: Implement stale-base-safe push, pull, listener convergence, and the mandatory V1→V2 race

**Files:**
- Modify: `lib/core/sync/engine/push_pipeline.dart`
- Modify: `lib/core/sync/engine/pull_pipeline.dart`
- Modify: `lib/core/sync/engine/sync_engine.dart`
- Test: `test/core/sync/push_pipeline_test.dart`
- Test: `test/core/sync/pull_pipeline_test.dart`
- Test: `test/core/sync/sync_engine_test.dart`
- Create or include in the above: explicit causal race regression test.

- [ ] **Step 1: Write the mandatory RED causal regression**

Exact sequence:
1. active UID/generation has accepted row version V1 in `sync_row_meta`;
2. local edit L occurs and journal freezes `knownVersion(V1)`;
3. before L promotes, remote update V2 is accepted/applied and advances `sync_row_meta` to V2;
4. promoter emits L with base **V1**, never V2;
5. conditional cloud commit rejects/reconciles L as stale under the approved LWW/CAS rules;
6. accepted V2 remains authoritative unless a later genuinely new local edit occurs against V2.

This test is a release-blocking amendment regression.

- [ ] **Step 2: Add push/outbox race tests**

Cover:
- null/known-absent create commits only if cloud remains absent;
- known-version update/delete loses to newer cloud state;
- delete writes tombstone, never physical Firestore delete;
- successful cloud acknowledgement is conditional on exact revision+mutation ID;
- failure acknowledgement is also conditional;
- local edit occurring while push is in-flight remains queued;
- flush serialization prevents overlapping drain/ack races;
- transient gateway failure retains durable work and diagnostics.

- [ ] **Step 3: Add pull/listener tests**

Cover matching mutation echo, newer remote live row, tombstone apply, initial-snapshot known absence, legitimate pending known-absent create preservation, generation-pointer change ordering, old-generation quarantine, and no remote-apply journaling.

- [ ] **Step 4: Run RED**

```bash
flutter test --no-test-assets test/core/sync/push_pipeline_test.dart test/core/sync/pull_pipeline_test.dart test/core/sync/sync_engine_test.dart
```

- [ ] **Step 5: Implement and run GREEN**

The first complete collection snapshot performs known-absence reconciliation. Reconnect after offline/error requests immediate flush. Ordinary local mutation notifications retain one 5-second debounce timer.

- [ ] **Step 6: Commit**

```bash
git add lib/core/sync/engine test/core/sync
git commit -m "feat(sync): enforce causal stale-base convergence"
```

---

### Task 10: Implement generation repository and B3 with `localMutationEpoch` protection

**Files:**
- Create/modify: `lib/core/sync/model/sync_generation.dart`
- Create/modify: `lib/core/sync/engine/generation_repository.dart`
- Modify: `lib/core/sync/bootstrap/full_push.dart`
- Modify: `lib/core/sync/bootstrap/full_pull.dart`
- Modify or remove: `lib/core/sync/cloud_progress_gateway.dart`
- Test: `test/core/sync/generation_repository_test.dart`
- Test: `test/core/sync/bootstrap/full_push_test.dart`
- Test: `test/core/sync/bootstrap/full_pull_test.dart`

- [ ] **Step 1: Carry forward unchanged generation/B3 tests from the base design**

Cover empty/no-generation, local-only meaningful, cloud-only meaningful including preferences-only generation, both-sides meaningful requiring explicit choice, complete staging before activation, complete download/validation before destructive replace, staging failure leaves prior active generation untouched, and successful pull preserves intentionally device-local in-progress mock state.

- [ ] **Step 2: Add amendment RED epoch-race tests**

**Keep this device:**
- capture epoch E before local snapshot;
- inject a concurrent local mutation causing E+1 after snapshot but before activation;
- activation must not be treated as current; retry/reconcile deterministically;
- no journal revision newer than the represented snapshot is acknowledged.

**Keep my account:**
- download/validate cloud snapshot;
- inject a concurrent local mutation before destructive replacement;
- epoch mismatch aborts replacement and preserves the concurrent local action;
- successful replacement atomically acknowledges only journal state proven represented.

- [ ] **Step 3: Add custom-track full snapshot tests**

Keep-this-device serializes authoritative `custom_track_meta_local` plus scope rows into typed `track_scope` documents. Keep-my-account parses/validates both typed shapes, writes authoritative metadata/scope + Sync metadata + projection-required marker in the local replacement transaction, then rebuilds projection afterward.

Projection failure after authoritative pull remains recoverable and blocks `upToDate`; it does not roll authority back.

- [ ] **Step 4: Run RED**

```bash
flutter test --no-test-assets test/core/sync/generation_repository_test.dart test/core/sync/bootstrap/full_push_test.dart test/core/sync/bootstrap/full_pull_test.dart
```

- [ ] **Step 5: Implement stage/activate and download-before-replace with epoch CAS**

Use exact generation paths from the base design:

```text
users/<uid>/sync_state/current
users/<uid>/sync_generations/<generationId>
users/<uid>/sync_generations/<generationId>/<collection>/<rowId>
```

Full push reads the registry/AppDatabase authority, not the content projection. Full pull materializes and validates all collection documents plus generation preferences before opening the replacement transaction.

- [ ] **Step 6: Run GREEN and commit**

```bash
flutter test --no-test-assets test/core/sync/generation_repository_test.dart test/core/sync/bootstrap/full_push_test.dart test/core/sync/bootstrap/full_pull_test.dart
git add lib/core/sync/bootstrap lib/core/sync/engine/generation_repository.dart lib/core/sync/model/sync_generation.dart lib/core/sync/cloud_progress_gateway.dart test/core/sync
git commit -m "feat(sync): guard B3 with local mutation epochs"
```

---

### Task 11: Implement eligibility/runtime state machine, identity boundaries, and lifecycle quiescence

**Files:**
- Create/modify: `lib/core/sync/eligibility/sync_claim_gateway.dart`
- Create/modify: `lib/core/sync/eligibility/sync_entitlement.dart`
- Create/modify: `lib/core/sync/runtime/sync_runtime_controller.dart`
- Create/modify: `lib/core/sync/runtime/sync_account_transition_gateway.dart`
- Modify: `lib/core/sync/sync_status.dart`
- Modify: `lib/core/sync/sync_coordinator.dart`
- Modify narrowly: `lib/core/auth/auth_repository.dart`
- Modify narrowly: `lib/app/auth_bootstrap.dart`
- Test: `test/core/sync/sync_eligibility_test.dart`
- Test: `test/core/sync/sync_runtime_controller_test.dart`
- Test: `test/core/sync/sync_account_transition_gateway_test.dart`
- Re-run affected Auth tests.

- [ ] **Step 1: Write RED eligibility/state tests**

Preserve frozen statuses: `SyncOff`, `SyncActivating`, `SyncReconciliationRequired`, `Syncing`, `SyncUpToDate`, `SyncOffline`, `SyncError`.

Cover:
- anonymous + Pro => off;
- named + Free => off;
- named + RevenueCat Pro + missing refreshed claim => activating and zero progress Firestore reads;
- fully eligible named Pro runs B3 before publishing stable active context;
- both meaningful blocks incremental promoter/engine until explicit choice;
- local-only/no-cloud and cloud-only/empty-local auto-resolve as approved;
- eligibility loss/quiescence clears stable active context immediately, so new local mutations become `unbound` and do not enter active outbox;
- restore reruns B3 and cannot blindly reuse old-generation outbox;
- account/UID switch cannot cause prior UID journal/outbox work to be retargeted;
- status cannot become `upToDate` with unacknowledged relevant journal, pending outbox, B3 work, or projection marker.

- [ ] **Step 2: Write account transition RED tests**

Pro ordinary sign-out: stop new promotion/listeners first, then required flush; failure propagates and Auth does not continue sign-out/wipe. Account switch/delete quiesce without flushing as already approved. Remove only the temporary Wave 2D Auth-side cloud-progress compatibility declarations.

- [ ] **Step 3: Run RED**

```bash
flutter test --no-test-assets test/core/sync/sync_eligibility_test.dart test/core/sync/sync_runtime_controller_test.dart test/core/sync/sync_account_transition_gateway_test.dart test/core/auth/auth_repository_sign_out_test.dart test/core/auth/auth_repository_collision_test.dart test/core/auth/auth_repository_privacy_test.dart
```

- [ ] **Step 4: Implement serialized runtime transitions**

Auth/entitlement events must not start concurrent B3 flows. Publish stable Sync active context only after eligibility + B3 establish the UID/generation. Clear it before quiescence/account transition so in-flight user edits safely journal as `unbound` if a transition races them.

- [ ] **Step 5: Run GREEN and commit**

```bash
flutter test --no-test-assets test/core/sync/sync_eligibility_test.dart test/core/sync/sync_runtime_controller_test.dart test/core/sync/sync_account_transition_gateway_test.dart test/core/auth/auth_repository_sign_out_test.dart test/core/auth/auth_repository_collision_test.dart test/core/auth/auth_repository_privacy_test.dart
git add lib/core/sync/eligibility lib/core/sync/runtime lib/core/sync/sync_status.dart lib/core/sync/sync_coordinator.dart lib/core/auth/auth_repository.dart lib/app/auth_bootstrap.dart test/core/sync test/core/auth
git commit -m "feat(sync): enforce runtime identity boundaries"
```

---

### Task 12: Wire production providers, startup recovery, lifecycle flush, and B3 UI

**Files:**
- Modify: `lib/core/sync/providers.dart`
- Modify: `lib/core/sync/sync.dart`
- Create/modify: `lib/app/sync_runtime_bootstrap.dart`
- Modify: `lib/app/bootstrap.dart`
- Modify: `lib/app/app.dart`
- Create/modify: `lib/features/settings/presentation/widgets/sync_reconciliation_gate.dart`
- Modify: `lib/l10n/app_en.arb`
- Test: `test/core/sync/providers_test.dart`
- Test: `test/app/sync_runtime_bootstrap_test.dart`
- Test: `test/features/settings/presentation/sync_reconciliation_gate_test.dart`
- Extend: custom-track projection recovery tests.

- [ ] **Step 1: Write RED composition/recovery tests**

Cover:
- configured Firebase composition uses real gateways/runtime and mutation recorder; unavailable Firebase remains safely off/local;
- RevenueCat entitlement is bridged from `lib/app/` into feature-neutral Sync state; `core/sync` does not import paywall feature code;
- startup/runtime sees projection-required marker and idempotently repairs the content projection before allowing `upToDate`;
- projection retry failure remains visible as unsettled Sync/local recovery state without losing app authority;
- app-background lifecycle forces immediate best-effort flush;
- Auth/entitlement changes reach runtime;
- B3 overlay is non-dismissible and offers only the two frozen choices.

Freeze English B3 copy from the base design:

```text
Title: Choose which progress to keep
Body: Pantas found progress on this device and in your account. Choose one copy to keep before syncing starts.
Buttons: Keep this device / Keep my account
```

- [ ] **Step 2: Run RED**

```bash
flutter test --no-test-assets test/core/sync/providers_test.dart test/app/sync_runtime_bootstrap_test.dart test/features/settings/presentation/sync_reconciliation_gate_test.dart test/core/sync/custom_track_projection_test.dart
```

- [ ] **Step 3: Implement startup/runtime binding and projection recovery**

Bind Sync after RevenueCat bootstrap. Preserve existing router/navigation state by wrapping the current child with the reconciliation gate. Do not add a background isolate or idle poller.

- [ ] **Step 4: Generate localization, run GREEN, commit**

```bash
flutter gen-l10n
flutter test --no-test-assets test/core/sync/providers_test.dart test/app/sync_runtime_bootstrap_test.dart test/features/settings/presentation/sync_reconciliation_gate_test.dart test/core/sync/custom_track_projection_test.dart
git add lib/core/sync/providers.dart lib/core/sync/sync.dart lib/app/sync_runtime_bootstrap.dart lib/app/bootstrap.dart lib/app/app.dart lib/features/settings/presentation/widgets/sync_reconciliation_gate.dart lib/l10n test
git commit -m "feat(sync): wire runtime and recovery lifecycle"
```

---

### Task 13: Run the amendment-specific completeness matrix

**Files:** Tests only unless a failing contract reveals a scoped source defect.

Create one focused matrix test or a clearly grouped set under `test/core/sync/` that proves every amendment requirement without relying only on broad integration tests.

- [ ] **Step 1: Boundary/local-only matrix**

Prove:
- producers do not receive UID/generation/cloud timestamps;
- anonymous/named-Free/activating/B3-pending/quiesced mutations stay `unbound` and out of active outbox;
- stable active mutation freezes exact UID/generation/causal base;
- known-absent differs from unbound;
- no prior UID/generation crosses a boundary.

- [ ] **Step 2: Causal race matrix**

Re-run explicit V1 local edit → V2 remote before promotion → stale V1 rejection/reconciliation.

- [ ] **Step 3: Queue race matrix**

Prove newer journal revision survives old promotion acknowledgement, newer outbox mutation survives old success/failure acknowledgement, and serialized flush preserves re-enqueued work.

- [ ] **Step 4: B3 epoch matrix**

Prove concurrent local mutations invalidate stale Keep-device activation and stale Keep-account destructive replacement; successful B3 acknowledges only represented revisions.

- [ ] **Step 5: Producer completeness matrix**

Explicitly exercise all ten sources, including `review_logs`, terminal-only `mock_exam_attempts`, both typed `track_scope` forms, and `custom_blueprints`.

- [ ] **Step 6: Custom-track matrix**

Prove create/rename/scope/delete, deterministic collision-safe IDs, full push, full pull, projection rebuild, projection-failure marker persistence, retry clearing, and content projection non-authority.

- [ ] **Step 7: Run matrix and commit**

```bash
flutter test --no-test-assets test/core/sync

git add test/core/sync lib/core/sync lib/core/storage/data lib/features/mock_exam/data
git commit -m "test(sync): lock amendment race contracts"
```

If no source repair is needed, commit only tests. Do not make unrelated cleanup changes.

---

### Task 14: Complete Wave 2E-1 verification and hand back a clean implementation branch

**Files:** No new production scope. Repair only defects exposed by required gates and keep repairs within Wave 2E-1 ownership.

- [ ] **Step 1: Re-establish frozen-base identity and generated state**

```bash
FROZEN=02cb557a343130ee1ac4eaf818451c790ae55ef3
git merge-base --is-ancestor "$FROZEN" HEAD
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

Expected: all commands exit 0. The coordinator's implementation branch may contain approved docs commits after the frozen source base; that is expected. Measure source scope against `$FROZEN`.

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

- [ ] **Step 3: Run directly affected storage/mock repository tests**

Run the exact producer tests added in Tasks 3–5, plus existing tests for the modified repositories. Record exact files and totals in handback.

- [ ] **Step 4: Analyze every changed Dart file**

```bash
CHANGED_DART="$(git diff --name-only "$FROZEN"...HEAD -- '*.dart')"
dart analyze $CHANGED_DART
```

Expected: no analyzer errors/warnings introduced by Wave 2E-1.

- [ ] **Step 5: Run non-rewriting canonical format gate**

```bash
dart format --output=none --set-exit-if-changed $CHANGED_DART
```

If formatting is required, format only the changed Dart surface, inspect, commit a formatting-only repair if needed, then rerun the non-rewriting gate.

- [ ] **Step 6: Run repository hygiene gates**

```bash
git diff --check "$FROZEN"...HEAD
dart run tool/check_no_ai_attribution.dart
git status --short --untracked-files=all
```

- [ ] **Step 7: Prove backend/rules and excluded ownership did not change**

```bash
if git diff --name-only "$FROZEN"...HEAD | grep -E '^(functions/|firestore\.rules$|firestore\.indexes\.json$)'; then
  echo 'STOP: certified backend/rules/index path changed'
  exit 1
fi
```

Also inspect the complete changed-path list and stop for payment-owned implementation, Android signing/release, content corpus, Sanity, Remote Config, telemetry Auth identity, or other excluded ownership.

- [ ] **Step 8: Re-run release-blocking race proofs explicitly**

At minimum rerun the exact focused tests for:
- V1 local causal base surviving V2 remote-before-promotion;
- journal revision N+1 surviving old promotion acknowledgement;
- outbox revision/mutation N+1 surviving old success and failure acknowledgement;
- Keep-device concurrent local mutation epoch rejection;
- Keep-account concurrent local mutation epoch rejection;
- old UID/generation not retargeted;
- custom-track projection failure/recovery and `upToDate` block;
- all ten producer sources.

- [ ] **Step 9: Final handback**

Report:
- exact frozen source SHA;
- exact implementation starting HEAD and final HEAD;
- every commit SHA/message;
- changed paths;
- schema version actually selected and migration result;
- build_runner/gen-l10n results;
- focused test files and totals;
- amendment completeness-matrix result;
- analyzer result;
- formatter result;
- `git diff --check` result;
- no-AI checker result;
- ownership/prohibited-path result;
- final tracked/untracked status;
- confirmation that no PR/merge/Actions/Firebase deployment/Google Play/Sanity mutation occurred.

Do not merge or fast-forward the persistent integration branch yourself.

---

## Implementation review checklist

Before declaring Wave 2E-1 complete, verify all answers are **yes**:

- Does every one of the ten logical sources create durable local mutation facts at its actual producer seam?
- Are domain callers free of UID/generation/cloud timestamp/mutation-ID knowledge?
- Are domain mutation + journal update + epoch advancement atomic?
- Are deletes journaled before authoritative rows disappear?
- Are `unbound`, `knownAbsent`, and `knownVersion` unambiguous and tested?
- Can a V1 journal event ever be silently rewritten to V2 at promotion? It must not.
- Can prior UID/generation work ever target a new UID/generation? It must not.
- Can an old promotion acknowledgement erase journal revision N+1? It must not.
- Can an old cloud success/failure erase or modify outbox mutation N+1? It must not.
- Can B3 activate/replace a snapshot after `localMutationEpoch` changed? It must not.
- Are in-progress mock attempts still device-local?
- Is custom-track metadata+scope authoritative in AppDatabase and the content row only a reconstructible projection?
- Does projection failure keep the recovery marker and block `upToDate`?
- Does full push use AppDatabase custom-track authority and full pull restore authority before projection?
- Are typed `track_scope` document IDs deterministic and collision-safe?
- Are certified backend/rules/index files unchanged?
- Is the superseded 2026-08-28 Dart implementation plan still treated as non-executable?
