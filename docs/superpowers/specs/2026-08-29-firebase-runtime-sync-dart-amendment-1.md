# Firebase Runtime Wave 2E-1 Dart Sync Amendment 1 — Local Mutation Boundary and Custom Track Authority

**Status:** Approved architecture, written amendment pending coordinator/user review

**Frozen planning base:** `02cb557a343130ee1ac4eaf818451c790ae55ef3`

**Amends:** `docs/superpowers/specs/2026-08-28-firebase-runtime-sync-r1-design.md`

**Supersedes for execution:** `docs/superpowers/plans/2026-08-28-firebase-runtime-sync-dart-r1.md`

The original Wave 2E Sync design remains authoritative except where this amendment explicitly changes or clarifies the Dart/client mutation boundary, B3 concurrency protection, and custom-track storage authority.

The original Dart implementation plan is not executable as written. It must not be used for implementation after this amendment. A replacement implementation plan will be written only after this amendment is reviewed and approved.

## 1. Why this amendment exists

Repository inspection found a concrete contradiction in the original Dart plan before any Wave 2E-1 implementation work began.

The original plan introduced non-null generation-bound fields such as `generationId` and `mutationId` into the Drift pending-sync schema before migrating the existing `PendingQueue` API and its callers. Drift regeneration would therefore make existing `PendingSyncCompanion.insert(...)` calls fail to compile before the task that was supposed to update the queue contract.

Moving that queue rewrite earlier would still be architecturally wrong. Existing feature/domain code calls the Sync pending queue directly but does not own or know:

- the active Firebase UID;
- the active Sync generation;
- the cloud timestamp the local edit was based on;
- the mutation identity used for conditional acknowledgement;
- whether the current account is Sync eligible.

Those values belong to Sync infrastructure, not quiz, review, lesson, assessment, mock-exam, or custom-track domain code.

The inspection also exposed two broader correctness gaps:

1. direct pending-queue instrumentation did not guarantee complete incremental coverage of every approved Sync source, including `review_logs`;
2. custom-track user data is split between the content database and the app database, so backing up only track scope could restore scope rows without restoring the custom track's identity and name.

This amendment fixes those boundaries without changing the already-approved user-visible Sync behavior or reopening the certified Wave 2E-2 backend contract.

## 2. Core ownership rule

Feature/domain code reports only one fact to Sync:

> A syncable local row changed.

Feature/domain code must not know or derive:

- Firebase UID;
- Sync generation ID;
- cloud `updatedAt` timestamps;
- `baseUpdatedAt`;
- cloud mutation IDs;
- Firestore document paths;
- Pro-claim state;
- B3 state.

A Sync-owned local mutation boundary records the local change. When Sync is active, that boundary also freezes the Sync-owned causal cloud context that existed when the local mutation occurred. The Sync runtime later decides whether and how that local fact becomes a generation-bound cloud mutation.

The implementation may name this boundary `LocalSyncMutationRecorder` or an equivalently narrow Sync-owned abstraction. The architectural contract matters more than the concrete class name.

## 3. Two-stage local mutation model

Wave 2E-1 must distinguish a local mutation journal from the active generation-bound cloud outbox.

### 3.1 Local mutation journal

Add a structured Drift table for durable local mutation facts. The expected conceptual name is `sync_local_mutations`.

Each journal entry represents the latest known local operation for one logical Sync row and contains enough information to survive process death, coalesce repeated local edits, and preserve the causal cloud state seen at mutation time when such state exists.

At minimum its conceptual fields are:

- `collection`;
- `rowId`;
- `op` (`upsert` or `delete`);
- `revision`;
- ordering/epoch information needed to relate the mutation to `localMutationEpoch`;
- nullable Sync-owned causal UID provenance;
- nullable Sync-owned causal generation provenance;
- an explicit causal-base state;
- nullable causal `baseUpdatedAt` used only when the causal-base state represents a known cloud version.

Its logical coalescing key is `(collection, rowId)`.

The causal-base state must distinguish at least:

- `unbound`: the local mutation happened while no stable active cloud generation could supply a causal base;
- `knownAbsent`: Sync knew the row did not exist in the active cloud generation when the local mutation happened;
- `knownVersion`: Sync knew the row's accepted cloud `updatedAt` when the local mutation happened.

A null timestamp must not ambiguously mean both `unbound` and `knownAbsent`.

The journal is still generation-neutral as a delivery queue: it is not permission to write to any UID/generation, contains no Firestore path, and contains no cloud mutation ID. Optional UID/generation provenance exists only to bind a frozen causal token to the cloud context in which that token was observed. Feature/domain code never supplies or interprets it.

When Sync is local-only, activating, B3-pending, quiesced, or otherwise lacks a stable active cloud context, the recorder writes an `unbound` journal event. When Sync is stably active, the Sync-owned recorder freezes the current causal row state at local mutation time.

### 3.2 Active generation-bound outbox

`pending_sync` remains the durable outbox for mutations that are ready to target one active cloud generation.

Its generation-aware contract must include, conceptually:

- `uid`;
- `generationId`;
- `collection`;
- `rowId`;
- `op`;
- nullable `baseUpdatedAt` plus enough base-state information to distinguish known absence from a known timestamp;
- `mutationId`;
- `revision`;
- `queuedAt`;
- existing retry/error bookkeeping as needed.

Its coalescing identity is `(uid, generationId, collection, rowId)`.

A Sync-owned promotion step enriches journal entries only when Sync is fully active. The implementation may name this component `SyncOutboxPromoter` or an equivalent narrow abstraction.

Promotion derives or validates:

- the currently authenticated eligible UID;
- the active generation ID;
- the frozen causal-base token captured by the journal recorder at mutation time;
- a new mutation identity;
- the active outbox revision.

Promotion must not reread a newer `sync_row_meta` value and substitute it as the local mutation's base. If the journal event carries a bound causal token, its causal UID and generation must exactly match the active UID and generation before normal incremental promotion is allowed.

No feature repository supplies those values.

## 4. Local-only and non-active states

The local mutation journal is valid in all local operating modes.

The following states must not create new generation-bound cloud outbox entries:

- anonymous Free;
- named Free;
- RevenueCat Pro while the refreshed Firebase `pro` claim is still absent (`activating`);
- B3 reconciliation pending;
- explicitly quiesced Sync;
- Pro-expired Sync.

During those states the local databases remain authoritative and user activity continues normally. Journal entries recorded in those states are `unbound` because no stable active cloud generation is permitted to supply their causal base.

When a user later becomes Sync eligible, B3 reconciles complete local/cloud state as already approved. The journal exists to preserve local mutation facts and race information; it does not turn local-only users into incremental cloud-sync users.

After B3 establishes an active generation, journal state represented by the successful reconciliation is acknowledged according to the B3 epoch/revision rules. Only later local mutations recorded against that stable active UID/generation may enter ordinary incremental promotion.

A journal mutation carrying causal provenance from an older UID or older generation must never be rebound to a new UID/generation by merely rereading current metadata. It is either acknowledged because the completed B3/generation transition proved it represented, or it remains blocked until the appropriate reconciliation path resolves it.

## 5. Atomic local mutation contract

For syncable user data whose authoritative state is in `AppDatabase`, three things must occur atomically in one Drift transaction:

1. the authoritative domain-state mutation;
2. the local journal mutation;
3. incrementing the monotonic local mutation epoch.

When Sync is stably active, the Sync-owned mutation recorder must freeze the row's causal cloud token as part of that journal mutation at the time of the local edit. It may obtain a Sync-owned active-context snapshot outside the domain layer, but the recorder must only bind the journal event to that UID/generation if that context is still valid for the transaction. If a lifecycle/generation transition makes the context unstable, the domain mutation still succeeds and the journal event is recorded as `unbound` instead of fabricating a cloud base.

For a stable active context, the causal token comes from the accepted `sync_row_meta` state that existed when the local mutation was recorded:

- accepted row absent → `knownAbsent`;
- accepted row present with cloud timestamp → `knownVersion` plus that timestamp.

A later remote update must not retroactively change the base of an already-recorded local mutation.

A delete must reach the journal in the same transaction in which the authoritative row disappears. Sync must never depend on rereading an already-deleted domain row merely to discover that a delete occurred.

Repeated changes to the same logical Sync row may coalesce in the journal, but coalescing must advance its revision. If a newer local edit happens after a remote apply has advanced `sync_row_meta`, that newer edit captures the newer causal token; an older in-flight promotion cannot acknowledge it.

## 6. `localMutationEpoch`

Add a monotonic engine-wide value in `sync_meta`, conceptually keyed as `localMutationEpoch`.

Every authoritative syncable local mutation increments it in the same local transaction that records the journal event.

The epoch is a B3 concurrency guard, not a cloud timestamp and not a per-row conflict version.

### 6.1 Keep this device

Before serializing the local full-push snapshot, capture the current epoch.

Before activating the staged cloud generation, verify that the epoch has not changed in a way that would make the staged snapshot stale.

If it changed, do not claim that the staged generation represents current local truth. Abort/retry/reconcile deterministically.

After successful activation, acknowledge only journal entries that are proven represented by the activated snapshot and whose relevant revisions/epoch relationship has not been superseded by a newer local action.

A concurrent study action must never disappear merely because a full push was already in progress.

### 6.2 Keep my account

Download and validate the complete active cloud generation before destructive local replacement, as required by the base design.

Capture/check the local mutation epoch around the reconciliation window.

Immediately before replacing local syncable state, verify that no new authoritative local mutation has occurred since the reconciliation snapshot became authoritative for the operation.

If the epoch changed, abort/retry instead of overwriting the concurrent local action.

The successful local replacement and the reset/acknowledgement of journal state represented by that replacement must occur atomically where they share `AppDatabase` authority.

## 7. Revision-safe journal promotion and outbox acknowledgement

Both local-journal promotion and cloud-outbox acknowledgement must be conditional on the exact version that was observed.

### Journal promotion

If the promoter reads journal revision `N`, it must not erase or mark complete a journal entry that has since advanced to revision `N+1`.

Promotion/removal must therefore use revision-conditional acknowledgement or an equivalent compare-and-set discipline.

Normal incremental promotion is allowed only for a journal event whose frozen causal provenance matches the currently active UID and generation and whose causal-base state is `knownAbsent` or `knownVersion`.

An `unbound` event is not converted into an ordinary incremental write by reading whatever `sync_row_meta` happens to exist later. It is resolved through B3/full-reconciliation semantics or acknowledged only when a generation transition proves that its local state was represented.

A bound event from a prior UID or prior generation is likewise never retargeted into the current generation.

### Active outbox

Re-enqueueing/coalescing a row into the active outbox creates a new mutation identity and advances its revision.

A drained batch carries the observed revision and mutation ID.

`markSuccess` and `markFailure` may update/remove the outbox row only if the stored row still matches the drained revision and mutation ID.

If the row changed while the cloud write was in flight, the newer mutation remains queued.

The flush loop is serialized. A prior UID or prior generation must never be able to send or acknowledge work under a later identity/generation.

This closes the existing race where an older drained batch can delete a newer coalesced mutation when it reports success.

## 8. Incremental producer coverage

Wave 2E-1 must provide mutation recording for every logical Sync source already approved by the base design:

1. `quiz_attempts`;
2. `assessments`;
3. `fsrs_cards`;
4. `lesson_progress`;
5. `lesson_bookmarks`;
6. `question_flags`;
7. `mock_exam_attempts` — terminal attempts only;
8. `review_logs`;
9. `track_scope`;
10. `custom_blueprints`.

`study_plan` remains inactive and is not added by this amendment.

An in-progress mock-exam attempt remains device-local. The transition to a terminal syncable mock state is the mutation boundary for that row.

The existing `track_scope` local semantics remain excluded-topic rows keyed by the custom track/exam identity and topic identity.

The replacement implementation plan must enumerate the concrete producer/repository seams for all ten logical sources so no worker is left to infer coverage ad hoc.

## 9. Custom-track authority correction

### 9.1 Problem

Custom-track identity/name and custom-track scope currently do not share one durable user-data authority suitable for full-device restore.

Backing up only scope can recreate exclusions without recreating the custom track they belong to.

### 9.2 App-database authority

Add an `AppDatabase` table for custom-track identity metadata, conceptually named `custom_track_meta_local`.

At minimum each authoritative custom-track metadata row contains:

- `examId` (the stable custom-track identity already used by the application);
- `name`.

This domain table must not gain cloud timestamps or Firestore-specific fields.

For Sync and recovery purposes, `AppDatabase` becomes the authoritative durable user-data copy of custom-track identity plus scope.

The existing content-database custom-track representation becomes a projection used by the application's current content/query/UI seams.

After this amendment, no content-database-only custom-track mutation may be the sole authoritative copy of user-created custom-track state.

## 10. Custom-track mutation semantics

Custom-track operations must update authoritative app-database state first and record their Sync mutation facts using the same journal/epoch rules as other Sync sources.

Conceptually:

- create: authoritative metadata upsert plus the required scope mutations;
- rename: authoritative metadata upsert;
- topic inclusion/exclusion changes: authoritative scope mutations;
- delete: authoritative metadata delete plus the required scope deletes/tombstones.

Where multiple authoritative `AppDatabase` rows are changed by one user action, those authoritative mutations, corresponding journal facts, and the mutation-epoch advancement must be committed consistently so a crash cannot leave Sync believing a partial custom-track operation is authoritative.

The content database is updated afterward as a recoverable projection.

## 11. Cloud representation of custom tracks

Do not add an eleventh Sync collection.

Use the already-approved and already-certified `track_scope` generation subcollection for both custom-track metadata and scope rows, with typed payloads and collision-free document IDs.

Conceptual metadata document:

```text
track--<examId>
kind: custom_track
examId: <examId>
name: <name>
```

Conceptual scope document:

```text
scope--<examId>--<topicId>
kind: scope
examId: <examId>
topicId: <topicId>
```

Both document types also carry the standard Wave 2E Sync envelope fields required by the base design/backend, including server-owned `updatedAt`, `originDeviceId`, `mutationId`, `schemaVersion`, and `deleted` semantics.

Document-ID encoding must be deterministic and collision-safe for the application's actual identifier character set. The implementation plan must require tests for round-trip mapping and non-collision instead of assuming raw delimiter concatenation is always safe.

### Backend compatibility

The certified Wave 2E-2 backend remains unchanged.

At certified backend head `cbfcb0275f0b0ed22624d23a11c7a41ebca676c5`, Firestore row validation constrains the required Sync envelope but does not restrict domain payload keys to a closed `hasOnly(...)` set. The typed `kind`, `examId`, `name`, and `topicId` payload fields therefore fit the existing certified `track_scope` row contract.

No new Firestore collection, Function, rule, or index is introduced by this amendment.

## 12. Content-database projection and crash recovery

Because application code currently consumes custom tracks through the content database, Wave 2E-1 must maintain that representation as a derived projection.

The projection must be idempotently reconstructible from authoritative app-database custom-track metadata and scope.

Use an engine-wide recovery marker in `sync_meta` to record that custom-track content projection repair is required.

For operations that change authoritative custom-track state:

1. commit authoritative `AppDatabase` state, journal facts, epoch advancement, and projection-required marker consistently;
2. update/rebuild the content-database projection;
3. clear the marker only after the projection succeeds.

If projection fails or the process exits between steps, authoritative app-database state remains intact and startup/runtime recovery retries the projection idempotently.

The exact startup/composition seam may follow the existing database bootstrap architecture, but the implementation must not make successful cloud Sync depend on treating the content database as the authority.

Sync must not report `upToDate` while the custom-track projection-required marker remains set.

## 13. Full-push custom-track behavior

A complete local snapshot for Keep this device must serialize both:

- authoritative custom-track metadata from `custom_track_meta_local`;
- authoritative excluded-topic scope rows.

Both are emitted into the active/staging generation's `track_scope` logical collection using the typed representation above.

The full-push snapshot must use app-database authority, not scrape the content projection as the canonical source.

The normal B3 epoch guard applies to custom-track metadata and scope exactly as it does to other syncable local state.

## 14. Full-pull custom-track behavior

Keep my account must parse and validate both typed `track_scope` document shapes before replacing local authoritative state.

The atomic local replacement stage writes:

- `custom_track_meta_local` metadata;
- authoritative local track-scope rows;
- corresponding Sync row metadata/journal state required by the successful pull;
- the projection-required recovery marker.

Only after the authoritative app-database replacement succeeds may the content-database projection be rebuilt.

Projection failure after the authoritative replacement is a recoverable local projection error. It must not roll back to stale cloud/local authority or silently declare Sync fully up to date.

## 15. Interaction with `sync_row_meta` and stale-base protection

The base design's structured `sync_row_meta` remains authoritative for the latest accepted per-cloud-row version knowledge.

The local journal does not replace it. The journal freezes the relevant accepted row state at mutation time when Sync has a stable active cloud context.

The responsibilities are distinct:

- domain tables: current local user-data truth;
- `sync_local_mutations`: durable fact that local truth changed, plus the Sync-owned causal token observed at mutation time when available;
- `sync_row_meta`: latest accepted cloud version/known-absence information for a logical cloud row;
- `pending_sync`: generation-bound mutation ready for active cloud delivery.

For an active local edit, the recorder reads the then-current accepted row state and freezes it into the journal event. Later remote acceptance may advance `sync_row_meta`, but that advancement does not rewrite the already-recorded event's causal base.

When that journal event is promoted, the promoter uses the frozen causal token. It must not substitute the current `sync_row_meta` value.

This is required for stale-base protection. Example: local edit L is recorded against cloud version V1; before L is promoted, a remote update advances the accepted row to V2. L must still attempt from V1 and therefore lose/reconcile as stale. Treating L as based on V2 would incorrectly erase the causal conflict.

`knownAbsent` is also a real causal state. It must be distinct from `unbound`, because a local create observed against a known-absent cloud row may be promoted normally, while a mutation recorded with no active cloud context must first pass through B3/reconciliation semantics.

This preserves the approved tombstone, causal-base, and LWW/CAS semantics without exposing them to feature/domain code.

## 16. Lifecycle interaction

The base design's lifecycle behavior is unchanged.

### Eligibility activation

B3 runs before normal incremental promotion into a newly active generation.

Only after B3 establishes the active source/generation may later local mutations recorded against that stable generation be promoted normally. Journal work represented by B3 is acknowledged with epoch/revision safety; unbound or prior-generation work is never silently rebound.

### Pro expiry

Quiesce cloud listeners/writes immediately as already approved.

Do not discard authoritative local data or the local mutation journal merely because cloud eligibility ended.

Generation-bound pending work must remain isolated to the UID/generation it was created for and must never be blindly replayed after a later restore. Restore reruns B3.

### Sign-out

The existing Pro ordinary-sign-out flush contract remains unchanged. Quiescence must prevent new generation-bound promotion while sign-out is being prepared.

### Account deletion

Deletion quiesces without flushing pending cloud mutations as already approved. Subsequent local wipe removes user data and Sync-local metadata according to the account-boundary contract.

## 17. Sync status invariants

`upToDate` requires all relevant local/cloud work to be settled.

At minimum Sync cannot report `upToDate` while any of these are true:

- local mutation journal contains relevant unacknowledged work;
- active generation outbox contains pending work;
- B3 reconciliation is pending or running;
- custom-track content projection recovery marker is set.

Local-only named/anonymous states retain their existing `off` semantics; the existence of local journal facts must not make a Free user appear cloud-synced or cloud-failing.

## 18. Drift migration ordering

The replacement implementation plan must make the schema/API transition compilable at every task boundary.

The next applicable Drift migration must introduce or revise the needed structured state together with compatible production APIs instead of adding required generated fields several tasks before their callers can compile.

Expected schema work includes:

- `sync_row_meta` from the base design;
- local `sync_local_mutations` including explicit causal-base state/provenance;
- authoritative `custom_track_meta_local`;
- generation-aware/revision-safe `pending_sync`.

Do not hard-code a schema version in this amendment. The replacement plan must inspect the then-current `AppDatabase.schemaVersion` before implementation and assign the next valid migration version.

Generated Drift code must remain reproducible and compilable at each committed implementation checkpoint.

## 19. Required verification implications

The replacement implementation plan must include focused evidence for the following amendment-specific contracts in addition to the base Wave 2E tests.

### Boundary and local-only behavior

- feature/domain mutation producers do not receive UID, generation ID, or cloud timestamps;
- anonymous/named-Free/activating/B3-pending/quiesced mutations remain unbound and do not enter an active outbox;
- eligible active mutation recording freezes the correct UID/generation and exact causal base at mutation time;
- `knownAbsent` is distinct from `unbound`;
- normal promotion uses the frozen causal token instead of rereading a later `sync_row_meta`;
- no prior UID/generation mutation crosses identity/generation boundaries.

### Causal race

- local mutation recorded against V1 remains based on V1 if a remote apply advances `sync_row_meta` to V2 before promotion;
- that stale V1 mutation is rejected/reconciled by the approved stale-base rules instead of being falsely promoted as based on V2;
- an unstable generation/lifecycle transition records the local mutation safely without fabricating a causal base.

### Queue races

- newer journal revision survives an older in-flight promotion acknowledgement;
- newer outbox revision/mutation ID survives an older cloud success acknowledgement;
- failure acknowledgement is also revision/mutation conditional;
- serialized flush does not lose re-enqueued work.

### B3 epoch races

- concurrent local mutation during Keep this device prevents stale snapshot activation from being treated as current;
- concurrent local mutation during Keep my account prevents destructive local replacement;
- successful B3 acknowledges only represented journal state.

### Producer completeness

Focused tests prove mutation recording for all ten approved logical sources, including `review_logs`, terminal-only `mock_exam_attempts`, `track_scope`, and `custom_blueprints`.

### Custom tracks

- create/rename/scope/delete update authoritative app state and mutation journal correctly;
- custom-track metadata and scope full-push into typed `track_scope` documents;
- typed document IDs are deterministic and collision-safe;
- full pull restores metadata and scope before projection;
- projection can be reconstructed from app-database authority;
- projection failure leaves recovery marker set and blocks `upToDate`;
- retry clears the marker only after projection succeeds;
- content projection cannot become the sole durable authority after the amendment.

## 20. Scope and exclusions

This amendment is Dart/client architecture only.

It does not authorize changes to:

- `firestore.rules`;
- `functions/**`;
- `firestore.indexes.json`;
- Firebase Console/deployments;
- RevenueCat/payment-owned implementation;
- Android signing/release infrastructure;
- content lesson/question/illustration corpora;
- Sanity runtime/content;
- Remote Config/force-update;
- telemetry Auth identity.

The already-certified backend target remains:

`codex/firebase-runtime-sync-backend-indexes-r1` at `cbfcb0275f0b0ed22624d23a11c7a41ebca676c5`.

The persistent integration branch remains pinned at the frozen planning anchor until the Dart line is separately implemented, verified, and integrated through the coordinator.

## 21. Execution gate

Do not resume Wave 2E-1 implementation using `docs/superpowers/plans/2026-08-28-firebase-runtime-sync-dart-r1.md`.

After this amendment is committed, self-reviewed, and approved by the user, write a replacement Dart implementation plan that incorporates this amendment and the unchanged portions of the base Sync design.

Only that replacement plan may be used for Codex or another implementation worker.