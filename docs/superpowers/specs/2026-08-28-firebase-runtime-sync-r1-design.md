# Pantas Firebase Runtime Wave 2E — Sync Runtime Design

**Date:** 2026-08-28<br>
**Status:** Frozen in-chat design; pending review of this committed spec<br>
**Coordinator branch:** `web/firebase-runtime-sync-design-r1`<br>
**Exact base:** `a101fc5334c1ac3355406328f1b1b5600280d60f` (`codex/firebase-runtime-integration`)<br>
**Depends on:** Wave 2C account boundary and Wave 2D Auth runtime<br>
**Implementation split:** Wave 2E-1 Dart/client runtime + Wave 2E-2 backend/rules

## 1. Purpose

Wave 2E turns the existing Sync skeleton into the production user-data Sync runtime for named Pro users.

The design keeps Auth responsible only for identity/account lifecycle. Sync owns backup eligibility, B3 reconciliation, Firestore generation state, local/cloud convergence, conflict handling, quiescence, and Pro transitions.

The implementation evolves the existing `lib/core/sync/` structure instead of rewriting it. Existing mappers, queue seams, bootstraps, coordinator seams, and tests remain useful, but placeholder behavior is replaced with the contracts below.

## 2. Non-negotiable account model

- Anonymous Free: local only.
- Named Free: local only.
- Named Pro: Sync eligible.
- A named account root `/users/{uid}` exists independently of backup activation.
- The named account root is account metadata, not Sync storage.
- Named Free users must not gain progress-backup reads or writes merely because their account root exists.
- Auth does not inspect cloud progress and does not perform B3.
- Sync starts only after identity is established and Sync eligibility is confirmed.

## 3. Sync eligibility

Sync is active only when all three conditions are true:

1. the Firebase session is named, not anonymous;
2. RevenueCat reports an active Pro entitlement;
3. a freshly refreshed Firebase ID token contains the custom claim `pro == true`.

RevenueCat remains the immediate client-side entitlement signal. The Firebase custom claim remains the server authorization signal.

After purchase or restore, RevenueCat may become Pro before the webhook-updated Firebase claim reaches the device. During that interval:

- the app remains fully usable locally;
- Sync remains paused;
- the UI exposes Sync as `activating`;
- the client refreshes the Firebase ID token until the Pro claim is observed or eligibility changes again.

On Pro expiry, the RevenueCat transition immediately makes Sync ineligible and quiesces it even if a previously issued Firebase token still contains `pro == true`.

Wave 2E must not modify RevenueCat-owned source files to implement this. Sync may consume the existing entitlement surface.

## 4. B3 reconciliation

Every local-only to Sync-eligible transition runs B3 before normal Sync starts. This includes first Pro activation and later Pro restoration after expiry.

B3 distinguishes **active-generation existence** from **meaningful progress** so an existing account generation that contains only account preferences is not silently discarded.

| Active cloud generation | Syncable device data | Meaningful cloud data | Result |
| --- | --- | --- | --- |
| none | none meaningful | n/a | stage/activate the current device snapshot, including account preferences, then start Sync |
| none | meaningful | n/a | automatically Keep this device |
| exists | none meaningful | either | automatically Keep my account, preserving the existing generation and account preferences |
| exists | meaningful | none meaningful | automatically Keep this device |
| exists | meaningful | meaningful | block normal Sync and show the reconciliation prompt |

The both-sides-meaningful case uses an immediate blocking modal wherever the user is in the app. The choices are exactly:

- **Keep this device**
- **Keep my account**

No record-level merge is offered during B3.

The prompt represents a whole-side choice. The implementation must not start normal Sync until the choice completes successfully.

For B3, "meaningful cloud data" means at least one non-deleted record in a Sync-owned meaningful collection. Account preferences by themselves do not force a conflict prompt. An existing generation containing only preferences is still preserved through the active-generation-exists rule above.

## 5. Syncable meaningful data vs wipe-sensitive local data

Wave 2C's `LocalStateWiper.hasMeaningfulProgress()` remains an account-lifecycle/privacy signal. It may count local state that is intentionally not cloud-synced, such as an in-progress mock attempt.

Wave 2E introduces a separate Sync-domain meaningful-data detector for B3. It asks whether there is meaningful **syncable** data.

This distinction is required because an in-progress mock attempt is intentionally device-local until terminal state. It must not force a B3 conflict and must not be destroyed by a full pull.

A full pull replaces only Sync-owned tables/state. It does not wipe intentionally device-local state.

## 6. Cloud generation model

The universal account root remains outside Sync.

Cloud state is organized as:

```text
/users/{uid}
    account metadata only

/users/{uid}/sync_state/current
    activeGenerationId
    schemaVersion
    updatedAt

/users/{uid}/sync_generations/{generationId}
    status                # staging | active | retired
    schemaVersion
    createdAt
    createdByDeviceId
    preferences           # account-scoped synced preferences

/users/{uid}/sync_generations/{generationId}/quiz_attempts/{id}
/users/{uid}/sync_generations/{generationId}/assessments/{id}
/users/{uid}/sync_generations/{generationId}/fsrs_cards/{id}
/users/{uid}/sync_generations/{generationId}/lesson_progress/{id}
/users/{uid}/sync_generations/{generationId}/lesson_bookmarks/{id}
/users/{uid}/sync_generations/{generationId}/question_flags/{id}
/users/{uid}/sync_generations/{generationId}/mock_exam_attempts/{id}
/users/{uid}/sync_generations/{generationId}/review_logs/{id}
/users/{uid}/sync_generations/{generationId}/track_scope/{id}
/users/{uid}/sync_generations/{generationId}/custom_blueprints/{id}
```

`study_plan` remains inactive until its real user-data table/runtime exists. Wave 2E must not invent a placeholder cloud contract for absent runtime data.

### 6.1 Sync-owned collections

Wave 2E must align the cloud registry with meaningful backed-up user data.

The active Sync set is:

- quiz attempts;
- assessment results;
- FSRS/review-state cards;
- lesson progress;
- lesson bookmarks;
- question flags;
- terminal mock-exam attempts;
- review logs;
- track-scope exclusions;
- custom user blueprints;
- account preferences stored on the generation document.

The following remain intentionally local/derived and are not generation data:

- anonymous/named-Free data while Sync is ineligible;
- in-progress mock attempts;
- streak state, because streak is derived from persisted activity/history;
- quiz-session transient state;
- daily new-card intro state;
- device preferences such as theme/locale/debug state;
- derived user-metrics artifacts/archetypes unless a later design explicitly promotes them to source data;
- Sanity/content database data.

Existing domain timestamps that already serve domain behavior are not Sync metadata and must not be repurposed as the Sync LWW clock.

## 7. Keep this device: stage, activate, retire

`Keep this device` never deletes the currently active cloud generation first.

The flow is:

1. quiesce normal Sync;
2. generate a fresh generation ID;
3. create that generation with `status = staging`;
4. upload the complete Sync-owned local snapshot into that staging generation;
5. only after all required uploads succeed, call the generation-activation backend operation;
6. the backend atomically switches `sync_state/current.activeGenerationId` and marks generation state appropriately;
7. normal Sync starts against the new active generation;
8. old generations are cleaned asynchronously later.

If staging fails, the old cloud generation remains active.

If activation fails, the staged generation remains inactive and retryable. The old cloud generation remains active.

The activation request includes the caller's expected current generation ID. The backend uses compare-and-swap semantics. If another device activated a different generation first, activation fails with a stable generation-conflict result and B3 is re-evaluated against the new current generation.

This prevents two concurrent `Keep this device` operations from silently overwriting each other's generation choice.

## 8. Keep my account: download before replace

`Keep my account` never wipes Sync-owned local state before the cloud snapshot has been downloaded successfully.

The flow is:

1. quiesce normal Sync;
2. resolve the current active generation;
3. download every required collection plus generation preferences;
4. validate/map the complete snapshot in memory/application structures;
5. only after all required reads succeed, run one local replacement transaction;
6. inside that transaction replace Sync-owned local rows, queue state, and per-row Sync metadata;
7. preserve engine-wide device identity metadata;
8. start listeners/normal Sync for that generation.

A failed cloud read leaves the existing local state untouched and retryable.

When another device changes `activeGenerationId`, the same safe replacement rule applies. Old-generation listeners stop immediately. Old-generation pending work remains quarantined until the new-generation snapshot is successfully committed locally. Once the replacement transaction succeeds, stale old-generation queue entries are removed as part of that replacement.

## 9. Local Sync metadata

The existing key/value `sync_meta` table remains for engine-wide state such as:

- device ID;
- current local generation ID;
- bootstrap/recovery markers;
- other small engine-wide values.

Wave 2E adds a structured `sync_row_meta` table for per-row cloud state.

Conceptual shape:

```text
sync_row_meta
  collection
  rowId
  updatedAt
  originDeviceId
  primary key (collection, rowId)
```

`updatedAt` is the last accepted Firestore server timestamp for that row.

Remote domain-row application and the corresponding `sync_row_meta` update must happen in the same Drift transaction. A failure must advance neither one.

A `sync_row_meta` entry is retained when a domain row is deleted by an accepted tombstone. That retained knowledge is what lets a device recognize a later physically removed tombstone as an already-known cloud deletion.

Domain tables do not receive new Sync timestamp columns.

## 10. Pending queue contract

The durable pending queue remains the source of offline write intent but gains the metadata required for generation-safe stale-base protection.

Each queued operation records at least:

- generation ID;
- collection/table type;
- row ID;
- operation (`upsert` or `delete`);
- the base cloud `updatedAt` observed when the local edit lineage began;
- a local queue revision/mutation identity sufficient to distinguish an acknowledgement from a newer local edit;
- existing retry/attempt metadata.

The unique identity must be generation-aware.

Repeated local edits to the same row coalesce. Coalescing keeps the original base cloud timestamp until that mutation lineage is acknowledged or superseded by accepted cloud state.

The queue must survive process death and connectivity loss.

## 11. Normal push semantics

Ordinary local mutations flush after a 5-second debounce.

Explicit flush triggers override the debounce for:

- app backgrounding;
- manual retry/refresh;
- connectivity restoration;
- sign-out preparation.

There is no idle polling timer.

For each queued row, Sync compares the queued base cloud timestamp with the current active-generation cloud document inside an online Firestore transaction.

- If the cloud timestamp still matches the queued base, the local mutation may be committed.
- If the cloud row has advanced beyond that base, the queued write is stale and must not acquire a newer server timestamp merely because it arrived late.
- If the queued base is non-null but the cloud document is now absent, the row is treated as a cloud deletion/garbage-collected tombstone and the stale local mutation does not recreate it.
- If the queued base is null and the cloud document is absent, the row is a legitimate new local row and may be created.
- The accepted cloud state wins stale-base conflicts and is reconciled locally.

Committed writes carry:

- the mapped domain payload for an upsert;
- `updatedAt = serverTimestamp()`;
- `originDeviceId`;
- a mutation identity used to recognize the server acknowledgement;
- `deleted = false` for live rows;
- `schemaVersion`.

A successful write is not allowed to erase evidence of a newer local edit that happened while the previous write was awaiting server acknowledgement. Queue revision/mutation identity is used to decide whether the acknowledgement clears the queue entry or merely advances its base timestamp for the newer local revision.

This preserves fast consecutive edits without putting Sync timestamps in the domain row.

## 12. Pull, initial-snapshot, and echo semantics

Firestore listeners watch only the current active generation.

Incoming live rows are evaluated against `sync_row_meta` and pending queue state.

- A matching mutation echo from this device adopts the authoritative server timestamp.
- If no newer local revision exists, the corresponding pending operation may be cleared.
- If a newer local revision exists, the echo advances that queued mutation's base timestamp instead of discarding the newer local intent.
- An incoming remote row newer than the last accepted local cloud metadata is applied.
- Older/equal non-echo data is ignored.

The initial complete snapshot for a collection also reconciles known absence:

- if a local row has retained `sync_row_meta` for this generation, has no legitimate pending new-row mutation, and the complete active-generation snapshot no longer contains that document ID, the cloud deletion wins and the local row is removed;
- a genuinely new local row with null base metadata and a pending create is not removed merely because it is not yet in the cloud.

This rule preserves delete convergence even when the original tombstone was physically garbage-collected before a very old device reconnects.

Every accepted remote apply or accepted known-absence delete updates the domain row and `sync_row_meta` atomically as applicable.

## 13. Deletes and tombstones

Normal Sync deletion uses durable tombstones instead of immediately deleting Firestore documents.

A tombstone keeps the stable document ID and writes:

```text
deleted: true
updatedAt: serverTimestamp()
originDeviceId: <device>
mutationId: <id>
schemaVersion: <n>
```

An accepted tombstone removes the local domain row and advances/retains `sync_row_meta` in the same local transaction.

Queued deletes carry the same base-cloud protection as upserts. An old offline device cannot resurrect a deleted row simply by reconnecting later.

Tombstones are retained for 90 days. Backend cleanup may physically delete tombstones older than that cutoff. The known-absence rules in sections 11 and 12 preserve convergence after physical cleanup.

Generation retirement/cleanup is separate from tombstone cleanup.

## 14. Mock attempts

The existing mock-exam contract remains intact:

- in-progress mock attempts are device-local;
- only terminal attempts (`completed`, `discarded`, `forfeited`) enter Sync;
- multi-device live continuation of an in-progress mock remains a non-goal.

The B3 Sync-meaningful detector therefore counts only terminal mock attempts.

A full pull must not delete or replace an in-progress mock attempt.

## 15. Sync lifecycle and Auth boundary

Wave 2E implements a real `AccountTransitionGateway` backed by Sync lifecycle operations.

### Sign-out

For a Sync-eligible Pro user:

1. quiesce listeners/new work;
2. attempt the required pending-data flush;
3. if flush fails, abort ordinary sign-out;
4. only after preparation succeeds may Auth continue with local wipe and identity sign-out.

For named Free/local-only state there is no cloud flush to perform, but Sync still quiesces before the Auth-side wipe.

### Existing-account switch

Before UID changes, Sync quiesces. Auth performs identity switching only. After the resulting identity/eligibility state is known, Sync owns B3.

Auth does not read cloud progress during collision handling.

### Delete account

Deletion is different from ordinary sign-out:

1. quiesce Sync;
2. cancel listeners/work;
3. do **not** flush pending local mutations;
4. Auth/backend deletion proceeds;
5. local state is wiped afterward by the existing account lifecycle.

### Pro expiry or other eligibility loss

On eligibility loss:

- stop accepting new Sync work immediately;
- cancel listeners before starting any new cloud operation;
- a Firestore transaction or batch already submitted to the SDK may finish, but the engine starts no subsequent network operation after observing ineligibility;
- an in-progress Keep-this-device staging flow stops before the next upload batch and leaves the generation inactive/staging;
- an in-progress Keep-my-account download that has not reached the local replacement transaction is discarded from temporary memory and leaves local data unchanged;
- preserve local data;
- preserve cloud generations;
- preserve pending local queue state in a non-running form where applicable;
- do not continue reading/writing simply because an old Firebase token still has `pro == true`.

A later restoration re-runs B3. There is no blind resume.

## 16. Auth compatibility cleanup

Wave 2D intentionally left a temporary `CloudProgressGateway` declaration in Auth for compatibility.

Wave 2E removes that temporary declaration from `lib/core/auth/auth_repository.dart` and relocates cloud meaningful-progress ownership fully into Sync.

`SyncCloudProgressGateway` or its replacement no longer imports Auth merely to implement an Auth-declared interface.

No other Wave 2D Auth behavior is reopened.

## 17. Runtime composition and UI surface

The production provider graph must no longer default to `FakeSyncEngine`.

The Sync-facing UI states are intentionally small:

- `off` — anonymous or named Free;
- `activating` — RevenueCat says Pro but the refreshed Firebase token has not yet confirmed `pro == true`;
- `reconciliationRequired` — B3 needs the blocking user choice;
- `syncing`;
- `upToDate`;
- `offline` — pending work retained safely on device;
- `error` — retryable failure; pending data retained.

The reconciliation prompt is app-level and blocking only for the both-sides-meaningful B3 case. It must not appear for automatic local-only/cloud-only/no-data transitions.

Wave 2E does not add the older draft's three-failure dot or 24-hour home banner. Those escalation surfaces can be added later if production evidence justifies them.

## 18. No background isolate in Wave 2E

Wave 2E does not introduce `DriftIsolate` or another dedicated Sync isolate.

Drift I/O is already asynchronous, Sync rows are small, and correctness/lifecycle complexity is the current risk. A background isolate is deferred until profiling demonstrates actual UI jank.

This decision does not change the cloud/data contract and can be revisited later.

## 19. Backend and Firestore rules

Wave 2E-2 owns the backend/rules half.

Firestore rules must enforce:

- anonymous users cannot read or write Sync state/generations;
- named Free users cannot read or write Sync state/generations;
- named Pro owners may read their Sync control document and allowed generation data;
- normal client mutation is allowed only in the active generation;
- named Pro owners may upload their own staging generation under constrained fields/path rules;
- generation activation itself is backend-owned;
- account-root metadata remains governed separately from Sync.

The activation callable:

- requires authenticated named Pro identity;
- operates only under the caller's UID;
- validates the requested staging generation;
- compares the caller's expected active generation with the actual current value;
- atomically updates the current-generation pointer and generation statuses;
- returns stable structured errors for authorization and generation conflicts.

Cleanup retention is exact for Wave 2E:

- tombstones: eligible for physical deletion after 90 days;
- abandoned staging generations: eligible for deletion after 7 days;
- retired generations: eligible for deletion after 30 days;
- the generation currently referenced by `sync_state/current` is never eligible for generation cleanup regardless of age.

Cleanup code must re-check active-generation identity at deletion time instead of relying only on a previously read candidate list.

Wave 2E implementation and verification do not deploy Functions or Firestore rules to production.

## 20. Failure behavior

Sync failures preserve user data.

- Offline: retain queue and stop destructive work.
- Firestore permission/claim mismatch: stop writes, refresh eligibility/token state, remain usable locally.
- Keep-this-device staging failure: old cloud generation stays active.
- Generation activation failure: staged generation remains inactive; old generation stays active.
- Keep-my-account download failure: local state remains untouched.
- Local remote-apply transaction failure: neither domain row nor row metadata advances.
- Eligibility loss mid-operation follows the exact stop rules in section 15.
- Sign-out flush failure: abort ordinary sign-out.
- Account deletion: never flush pending Sync data first.

Transient infrastructure failure must not silently drop pending work.

## 21. Implementation split

After this design and its implementation plan are frozen, two workers may start in parallel from the same exact integration SHA.

### Wave 2E-1 — Dart/client runtime

Owns primarily:

- `lib/core/sync/**`;
- Sync-owned Drift schema/migration changes;
- minimal Auth compatibility cleanup for the temporary `CloudProgressGateway` declaration;
- runtime composition/provider wiring;
- the minimal reconciliation UI gate;
- focused Dart/Flutter tests.

It must not modify Firebase rules/Functions implementation except shared contract documentation explicitly assigned by the plan.

### Wave 2E-2 — backend/rules

Owns primarily:

- `firestore.rules`;
- Functions generation activation/cleanup code;
- Functions exports as required;
- backend/rules tests.

It must not modify Dart runtime implementation.

The implementation plan must assign any unavoidable shared path to only one worker or sequence that path before parallel work. Workers must not edit the same source file independently.

## 22. Verification contract

### 22.1 Wave 2E-1 must prove

- migration creates structured `sync_row_meta` safely;
- existing domain tables do not gain new Sync timestamp columns;
- pending queue is generation-aware and carries base-cloud/revision metadata;
- Sync meaningful-progress semantics cover all Sync-owned meaningful data and exclude intentionally device-local state;
- active-generation existence is distinguished from meaningful cloud progress so account preferences are preserved;
- all B3 matrix outcomes;
- both-sides case enters blocking reconciliation state;
- three-part eligibility gating;
- token-claim delay produces `activating`, not destructive failure;
- Pro expiry quiesces and restoration re-runs B3;
- Keep this device stages before activation and leaves old generation active on failure;
- Keep my account downloads before replacing local Sync-owned state;
- in-progress mock attempt survives full pull;
- generation-pointer changes quarantine old-generation queue work until replacement succeeds;
- stale-base writes cannot become winners merely by arriving later;
- acknowledgement/echo handling does not lose a newer same-device local edit;
- tombstones propagate deletes;
- a known row still converges to deletion when its tombstone has already been physically garbage-collected;
- a legitimate new local row with null base is not mistaken for a garbage-collected deletion;
- pending queue survives/retries transient failures;
- sign-out preparation flushes and can abort Auth sign-out;
- delete-account preparation does not flush;
- temporary `CloudProgressGateway` declaration is removed from Auth;
- production provider composition no longer defaults to `FakeSyncEngine`;
- focused analyzer/tests, canonical Dart formatting, `git diff --check`, and no-AI-attribution checks pass.

### 22.2 Wave 2E-2 must prove

- Functions tests for generation activation authorization and compare-and-swap conflict handling;
- Firestore emulator rules deny anonymous Sync access;
- Firestore emulator rules deny named-Free Sync access;
- Firestore emulator rules allow only the named Pro owner as designed;
- inactive retired generations cannot receive normal client mutations;
- staging generation permissions are constrained as designed;
- activation cannot target another user's generation;
- tombstone cleanup respects the 90-day cutoff;
- abandoned staging cleanup respects the 7-day cutoff;
- retired-generation cleanup respects the 30-day cutoff;
- generation cleanup cannot delete the active generation, including if the active pointer changes during cleanup;
- focused Functions/rules checks and repository hygiene pass.

### 22.3 Combined verification

After 2E-1 and 2E-2 are integrated, a separate verifier must run the cross-boundary checks, including emulator-backed named-Pro/named-Free/anonymous behavior and B3 generation transitions.

Only after combined verification may production Sync activation or Firebase deployment be considered. Any actual Firebase/Google/Play/Sanity mutation remains separately authorized.

## 23. Explicit non-goals

Wave 2E does not:

- deploy Firebase Functions or rules;
- change RevenueCat product/paywall behavior;
- modify Android signing/release infrastructure;
- modify content corpus files;
- sync Sanity/content database state;
- implement self-service data export;
- add telemetry Auth identity;
- add Remote Config/force-update work;
- add background scheduled sync/WorkManager;
- add a Sync background isolate;
- implement record-level merge during B3;
- sync in-progress mock attempts;
- add broad accessibility redesign;
- merge anything to `main`.

## 24. Frozen decisions summary

1. Sync is named-Pro only.
2. Eligibility requires named identity + RevenueCat Pro + refreshed Firebase `pro` claim.
3. Claim delay shows `activating`; study remains local-first.
4. B3 runs on every transition into Sync eligibility.
5. Active-generation existence is distinct from meaningful progress so a preferences-only cloud generation is preserved.
6. Both-sides-meaningful B3 is an immediate blocking Keep-device/Keep-account choice.
7. B3 never performs record-level merge.
8. `/users/{uid}` remains account metadata, not backup storage.
9. Sync uses a dedicated current-generation control document and versioned generation data.
10. Keep this device is stage -> activate -> retire/cleanup, never delete-then-upload.
11. Generation activation uses compare-and-swap against the expected active generation.
12. Keep my account downloads completely before local replacement.
13. `sync_meta` stays engine-wide key/value state.
14. `sync_row_meta` stores structured per-row LWW metadata and retains accepted deletion knowledge.
15. Remote row apply and row-metadata update are one Drift transaction.
16. Pending operations carry generation ID and base cloud timestamp.
17. Same-device acknowledgement handling must preserve newer local revisions.
18. Normal conflicts are server-ordered LWW with stale-base protection.
19. A missing cloud document with a non-null known base is treated as a cloud deletion, while a null-base pending create may create it.
20. Initial complete snapshots reconcile known absent rows so tombstone GC cannot resurrect them.
21. Deletes use tombstones.
22. Tombstones are retained 90 days.
23. Abandoned staging generations are retained 7 days; retired generations 30 days; active generation is never cleanup-eligible.
24. In-progress mock attempts remain device-local; terminal attempts sync.
25. Syncable meaningful-data detection is separate from wipe-sensitive local-state detection.
26. Sync registry includes review logs, track scope, and custom user blueprints so meaningful backed-up user data is not silently omitted.
27. No background isolate is introduced in Wave 2E.
28. No idle polling timer is introduced.
29. Pro expiry/eligibility loss starts no new cloud operation after the loss is observed; restoration re-runs B3.
30. Ordinary sign-out may abort if the required Pro flush fails.
31. Account deletion quiesces without flushing pending changes.
32. Cloud progress ownership moves fully out of Auth in Wave 2E.
33. 2E-1 and 2E-2 may run in parallel only after the implementation plan assigns disjoint file ownership.
34. No production external mutation occurs as part of Wave 2E implementation or verification.
