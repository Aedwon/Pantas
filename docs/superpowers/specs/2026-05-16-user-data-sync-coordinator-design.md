# Spec 3 — User-data SyncCoordinator

**Date:** 2026-05-16
**Status:** Draft, pending user review
**Critical-path position:** 3 of 11 (depends on Specs 1 + 2; unblocks Specs 6, 7, 8, 11)
**Owner:** Aerol Balayon
**Target soft launch:** 2026-06-28 (Android-only)

---

## 1. Purpose

Implement the two interfaces Spec 1 left as seams — `SyncCoordinator` (with `pushLocalToCloud()` / `pullCloudToLocal()`) and `LocalStateWiper` (with `wipeAll()` / `hasMeaningfulProgress()`) — and build the engine behind them so that user-data in `app.db` is mirrored to Firestore for the named-user subset, with multi-device convergence and durable offline behavior.

The engine is the backbone that lets a user reinstall the app, sign in on a second device, or recover from a lost phone without losing their progress. Its non-existence is the reason Specs 6/8/11 stay paper-only until this lands.

---

## 2. Scope

**In scope:**

- A new module `lib/core/sync/` containing the engine, mappers, bootstrap routines, and Riverpod surface.
- Per-row last-writer-wins sync between `app.db` user-data tables and Firestore subcollections under `/users/{uid}/`.
- Real-time Firestore listeners on the pull side for near-live multi-device convergence.
- Debounced batched push (5s window, with explicit override triggers) on the push side.
- Background-isolate engine (Drift's `DriftIsolate`) so flushes and snapshot application never jank the UI.
- A persistent Drift-backed `pending_sync` queue that survives app kill and replays on reconnect.
- Two-step migration routines (`pushLocalToCloud()` / `pullCloudToLocal()`) consumed by Spec 1's sign-in flow.
- A new callable Cloud Function `resetCloudUserData` to make the merge-prompt "Keep this device" intent atomic.
- A layered failure surface: silent retries with exponential backoff, then a Settings-tab dot after 3 consecutive failures, then a home-tab banner after 24 hours of continuous failure.
- Splitting `app_preferences_local_table` into a device-local half (`device_prefs`) and a synced half (`account_prefs`).

**Out of scope:**

- Anonymous-user sync. Per Spec 1 D1, anonymous users do not write to Firestore. The engine is a no-op while `currentUser.isAnonymous == true`.
- Pro entitlement sync. RevenueCat is the source of truth (Spec 7).
- Sanity content sync. `content.db` is owned by Spec 2 and never touched by this engine.
- Streak persistence in cloud. Streak is derived locally from `quiz_attempts`.
- `quiz_nudge_dismissed` sync — device-local UI nag-state.
- Theme + locale sync (per Spec 1 D7, these survive sign-out — device-local-only).
- WorkManager / scheduled background sync. Foreground listeners + flush-on-background are sufficient.
- Server-side aggregations / counters. Spec 11 computes progress locally from synced rows.

---

## 3. Key decisions (with rationale)

### D1 — Sync model: per-row LWW with real-time listeners

Each synced row has a stable client-generated ID, an `updatedAt` field stamped by `serverTimestamp()` on write, and an `originDeviceId` tag. Pushes are per-row writes batched into `WriteBatch`es; pulls are delivered by real-time Firestore listeners on each subcollection.

**Why:** This is the only model that is both safe (no silent multi-device overwrites) and good UX (other-device writes appear within seconds, not on sign-out/sign-in). A backup-and-restore model (whole-record overwrite) would silently clobber the second device's writes — a sharp failure mode for a learning app where lost progress translates to lost trust. A periodic-polling alternative offers no UX upside over listeners and adds explicit cadence logic that wakes the radio. The cost paid is ~8–10 days of engine work vs ~3 for backup-restore; the engine work is paid once and unlocks Spec 11's multi-device progress correctness for free.

**Fallback:** none needed. The model degrades gracefully — a single-device user sees a strictly local-feeling experience; the engine is invisible to them.

### D2 — Push side: debounced 5s batch flush

Drift mutations on synced tables enqueue dirty `(table, rowId, op)` rows in `pending_sync`. A 5s debounce timer drains the queue into a single Firestore `WriteBatch` (≤500 ops per batch). Explicit triggers override the debounce: app backgrounded, manual Refresh in Settings, pre-sign-out, post-purchase, connectivity reconnect.

**Why:** A heavy study session (20 questions in 5 minutes) issues ~40 Drift mutations across `quiz_attempts` and `fsrs_cards`. Immediate-write-through would emit 40 Firestore writes — quota and radio cost without UX benefit, since the pull side is real-time anyway. The 5s window is short enough that multi-device convergence stays under ~7s end-to-end; long enough that natural session bursts coalesce to ~1–2 batches.

**Fallback:** if quota cost surprises us post-launch, the window can grow to 15s or 30s with a one-line change. UX cost is purely "other-device delay during a session," not data integrity.

### D3 — Pull side: per-subcollection real-time listeners

On sign-in (and on app cold start while named), the engine opens a `Query.snapshots()` listener on each of the six synced subcollections. Listeners apply incoming `DocChange`s to Drift, using `originDeviceId` to recognize echoes of the local device's own writes and `updatedAt.serverTimestamp` for LWW comparisons against everything else.

**Why:** Listeners are Firestore's natural primitive for multi-device sync; the SDK handles reconnect, snapshot replay, and offline-cache reconciliation for free. The alternative (polling pulls on a 60s timer) wastes battery and burns reads on idle sessions. Echo recognition is the subtle bit: without it, the listener's redelivery of our own pushed write could fight an in-flight local write. The `originDeviceId` tag (a small string in `sync_meta`) makes echo detection a string comparison rather than a clock game.

**Fallback:** none needed. If listener behavior surprises us, polling is additive — a single class swap in `pull_pipeline.dart`.

### D4 — Conflict arbitration: `serverTimestamp()` LWW

Every synced row carries an `updatedAt` field written as `FieldValue.serverTimestamp()` on each push. The server stamps it. Local Drift rows carry a tentative client-clock `updatedAt` between issue-write and listener-echo; on echo, the server's value replaces it. Incoming listener events with `updatedAt > local.updatedAt` win; equal or older are discarded.

**Why:** Client clocks lie (timezone changes, NTP skew, user manipulation). Server time is the only globally consistent comparator available. Firestore's `serverTimestamp()` is purpose-built for this; using anything else introduces correctness bugs that surface as occasional silent data loss.

### D5 — Migration: wipe-and-replace, not LWW merge

`pushLocalToCloud()` calls the `resetCloudUserData` Cloud Function first (deletes the six subcollections cleanly), then pushes everything in `app.db`. `pullCloudToLocal()` calls `LocalStateWiper.wipeAll()` first, then opens listeners and waits for the first snapshot from each collection.

**Why:** The merge-prompt copy ("The other will be discarded") promises wipe-and-replace; naive LWW would leave unique rows on the discarded side alive and intact, silently violating user intent. Putting the wipe on the Cloud Function side (vs client-driven recursive delete) gives transactional finality — a flaky client can't leave the cloud half-deleted.

**Fallback:** none. The semantics are user-facing and locked by the merge-prompt copy in Spec 1.

### D6 — Failure surface: layered, never give up

| Layer | Trigger | UX |
|---|---|---|
| 0 | Any sync failure | Silent. Exponential backoff: 1s, 2s, 4s, …, ceiling 30 min. Connectivity reconnect resets to zero. |
| 1 | 3 consecutive failures | Small dot on Settings tab icon. Tap-through to Settings → Sync diagnostics. |
| 2 | 24 hours of continuous failure | Dismissable banner on home tab: "Your progress isn't syncing." Tap → Settings → Sync diagnostics with manual retry. |
| 3 | Forever | Queue is never truncated. Drift size cap is in practice ~500KB for a heavy month — fine. |

**Why:** The common failure case is transient network — invisible retries cover ~95% of the surface. Engaged users get an early warning at Layer 1 without nagging the rest. A 24h escalation window separates "transient" from "actually broken" cleanly. Never-give-up policy means a user who returns from a month offline still flushes everything, no special recovery flow needed.

**App Check failures** are treated as ordinary retryable errors at Layer 0; the banner at Layer 2 is generic ("Your progress isn't syncing") and never names integrity (defense in depth, per Spec 1).

### D7 — Background isolate for the engine

The sync engine runs on its own isolate via Drift's `DriftIsolate`. Mappers, `pending_sync` reads/writes, and `WriteBatch` commits all happen off the main isolate. The main isolate sees only `Stream<SyncStatus>` and Drift change notifications.

**Why:** A large flush (e.g., a 400-row catch-up after a long offline period) would otherwise jank the UI for ~100–300ms. The cost is one isolate-port boundary per `SyncStatus` update and per Drift change stream — negligible compared to a frozen frame.

### D8 — `app_preferences` split: `device_prefs` (local) + `account_prefs` (synced)

The existing `app_preferences_local_table` is split. `device_prefs` carries theme, locale, and debug flags — never synced, never wiped (Spec 1 D7). `account_prefs` carries reminder time, strict mock mode, future Study Plan settings — synced as a JSON blob in the `/users/{uid}.preferences` field that Spec 1's rules already allow updates to.

**Why:** Two preferences with different lifecycles can't share a table. Theme should survive sign-out and stay device-specific (the user picked dark on their phone for a reason). Reminder time should follow the user across devices. Coupling them forces a wrong choice for one or the other.

---

## 4. Architecture

```
   ┌─────────────────────────────────────────────────────────────────────┐
   │ App (Riverpod consumers)                                            │
   │   attemptsRepo · lessonProgressRepo · reviewStateRepo · …            │
   │   syncStatusProvider  (Stream<SyncStatus> for Spec 8 diagnostics)    │
   └────────────────────────┬────────────────────────────────────────────┘
                            │ Drift reads/writes              ▲
                            ▼                                 │ status stream
   ┌─────────────────────────────────────────────────────────────────────┐
   │ app.db (Drift, SQLCipher)                                           │
   │   attempts, assessment_results, review_state (FSRS),                │
   │   lesson_progress, mock_exam_attempts*, study_plan*,                │
   │   account_prefs, device_prefs, streak_local,                        │
   │   quiz_nudge_dismissed, pending_sync, sync_meta                     │
   └────────────────────────┬────────────────────────────────────────────┘
                            │ table-change observers
                            ▼
   ┌─────────────────────────────────────────────────────────────────────┐
   │ lib/core/sync/ — engine runs on background isolate                  │
   │   ┌─────────────────┐    ┌─────────────────┐                        │
   │   │ PushPipeline    │    │ PullPipeline    │                        │
   │   │  debounce 5s    │    │  per-subcoll    │                        │
   │   │  WriteBatch≤500 │    │  listeners      │                        │
   │   │  backoff        │    │  echo recog     │                        │
   │   └────────┬────────┘    └────────┬────────┘                        │
   │            │ uses                  │ uses                            │
   │            ▼                       ▼                                 │
   │   ┌──────────────────────────────────────┐                          │
   │   │ Mappers (one per doctype)            │                          │
   │   │   Drift row ↔ Firestore doc          │                          │
   │   └──────────────┬───────────────────────┘                          │
   └──────────────────┼──────────────────────────────────────────────────┘
                      │ Firestore SDK
                      ▼
   ┌─────────────────────────────────────────────────────────────────────┐
   │ Firestore — /users/{uid}/                                           │
   │   preferences (root-doc field)                                      │
   │   /quiz_attempts/{id}        /lesson_progress/{lessonId}            │
   │   /assessments/{id}          /fsrs_cards/{cardId}                   │
   │   /study_plan/{docId}        /mock_exam_attempts/{id}               │
   └─────────────────────────────────────────────────────────────────────┘
                      ▲
                      │ callable
   ┌─────────────────────────────────────────────────────────────────────┐
   │ Cloud Functions (Spec 1's functions/ dir)                           │
   │   resetCloudUserData — wipes /users/{uid}/** subcollections         │
   │                        (root doc + audit logs untouched)            │
   └─────────────────────────────────────────────────────────────────────┘

* mock_exam_attempts and study_plan tables are added in Specs 5 and 6;
  this spec defines the mapper + listener registration shape so adding
  them is one entry per table in the engine's collection registry.
```

### 4.1 Module layout

```
lib/core/sync/
  sync.dart                          ← barrel
  sync_coordinator.dart              ← impl of Spec 1's SyncCoordinator
  local_state_wiper.dart             ← impl of Spec 1's LocalStateWiper
  sync_status.dart                   ← sealed union
  providers.dart                     ← Riverpod surface
  engine/
    sync_engine.dart                 ← orchestrator on bg isolate
    push_pipeline.dart               ← debounce + WriteBatch flush
    pull_pipeline.dart               ← listener fan-out, snapshot apply
    backoff_policy.dart              ← exponential, ceiling 30min
    pending_queue.dart               ← Drift-backed pending_sync ops
    collection_registry.dart         ← single source of truth: synced
                                       table → subcoll name → mapper
  mapping/
    mapper.dart                      ← abstract Mapper<T>
    attempt_mapper.dart
    assessment_mapper.dart
    fsrs_card_mapper.dart
    lesson_progress_mapper.dart
    study_plan_mapper.dart           ← stub until Spec 6
    mock_exam_attempt_mapper.dart    ← stub until Spec 5
    preferences_mapper.dart          ← syncs as root-doc JSON field
  bootstrap/
    full_push.dart                   ← used by pushLocalToCloud()
    full_pull.dart                   ← used by pullCloudToLocal()
  device_id.dart                     ← lazy-load originDeviceId
                                       from sync_meta

lib/core/storage/data/tables/
  pending_sync_table.dart            ← (rowId, tableType, op, queuedAt,
                                        attempts, lastError, lastAttemptAt)
  sync_meta_table.dart               ← key/value: lastSyncedAt, failedSince,
                                        bootstrapState, deviceId,
                                        pending_full_push, pending_full_pull
  device_prefs_table.dart            ← split from app_preferences_local_table
  account_prefs_table.dart           ← split from app_preferences_local_table
```

**Isolation invariant:** only `lib/core/sync/` and its mappers import `cloud_firestore`. The rest of the app talks to Drift repositories (unchanged) or `syncStatusProvider`. Adding a new synced table is: add the Drift table, write a mapper, register it in `collection_registry.dart`.

### 4.2 Riverpod surface

| Provider | Type | Purpose |
|---|---|---|
| `syncEngineProvider` | `Provider<SyncEngine>` | Singleton; spawns bg isolate on first `read` |
| `syncStatusProvider` | `StreamProvider<SyncStatus>` | Spec 8 diagnostics; UI banner triggers |
| `syncCoordinatorProvider` | `Provider<SyncCoordinator>` | Implements Spec 1 interface |
| `localStateWiperProvider` | `Provider<LocalStateWiper>` | Implements Spec 1 interface |

```dart
sealed class SyncStatus {
  const factory SyncStatus.idle({DateTime? lastSyncedAt}) = _Idle;
  const factory SyncStatus.bootstrapping({
    required _BootstrapDirection direction,
    required int collectionsReady,
    required int collectionsTotal,
  }) = _Bootstrapping;
  const factory SyncStatus.syncing({required int pendingCount}) = _Syncing;
  const factory SyncStatus.ok({
    required DateTime lastSyncedAt,
    required int pendingCount,
  }) = _Ok;
  const factory SyncStatus.partialFailure({
    required List<String> failedCollections,
  }) = _PartialFailure;
  const factory SyncStatus.offline({required int pendingCount}) = _Offline;
  const factory SyncStatus.failedSince({required DateTime since}) = _FailedSince;
}
```

---

## 5. Data model

### 5.1 Drift additions to `app.db` (migration v(N+1))

```
pending_sync_table
  id            INTEGER PRIMARY KEY AUTOINCREMENT
  tableType     TEXT NOT NULL           -- 'quiz_attempts' | 'fsrs_cards' | ...
  rowId         TEXT NOT NULL           -- stable id within that table
  op            TEXT NOT NULL           -- 'upsert' | 'delete'
  queuedAt      DATETIME NOT NULL
  attempts      INTEGER NOT NULL DEFAULT 0
  lastError     TEXT
  lastAttemptAt DATETIME
  INDEX (tableType, rowId)              -- coalesce dup enqueues
  INDEX (queuedAt)                      -- FIFO drain order

sync_meta_table
  key   TEXT PRIMARY KEY
  value TEXT NOT NULL
  -- known keys:
  --   'lastSyncedAt'        ISO8601
  --   'failedSince'         ISO8601 | null (cleared on first success)
  --   'deviceId'            stable per-install UUIDv4
  --   'pending_full_push'   '1' | absent
  --   'pending_full_pull'   '1' | absent
  --   'consecutiveFailures' int
  --   'bootstrapState'      'idle' | 'pushing' | 'pulling' | 'ready'

device_prefs_table                       -- split from app_preferences
  key   TEXT PRIMARY KEY
  value TEXT NOT NULL
  -- known keys: theme, locale, debug flags

account_prefs_table                      -- split from app_preferences
  key   TEXT PRIMARY KEY
  value TEXT NOT NULL
  -- known keys: reminder_time, strict_mock_mode, language,
  --             (Spec 6) study_plan_pace_dial
```

Existing `app_preferences_local_table` is dropped after a one-way migration step in the Drift `MigrationStrategy` (read every row, classify by key, route to the new tables).

### 5.2 Firestore document shape

Every synced doc has these fields in common:

```
{
  ...row fields per table...
  updatedAt:       <serverTimestamp>,    // canonical LWW comparator
  originDeviceId:  <string>,             // local sync_meta.deviceId at write time
  schemaVersion:   <int>,                // per-doctype (mirrors Spec 2 discipline)
}
```

`/users/{uid}` root doc carries (in addition to Spec 1's fields):

```
{
  preferences: { ...account_prefs as a flat object... },
  ...
}
```

**Synced fields are written via `set(..., SetOptions(merge: true))`** to preserve fields the server may have added (e.g., audit timestamps written by Functions in future specs).

### 5.3 `LocalStateWiper.wipeAll()` — definitive scope

Spec 1 D7 listed the wipe scope using placeholder names. This spec implements `LocalStateWiper`, so the authoritative scope lives here.

| Table | Action on `wipeAll()` |
|---|---|
| `quiz_attempts` (synced) | Truncate |
| `assessment_results` (synced) | Truncate |
| `review_state` / FSRS cards (synced) | Truncate |
| `lesson_progress` (synced) | Truncate |
| `mock_exam_attempts` (synced, Spec 5) | Truncate |
| `study_plan` (synced, Spec 6) | Truncate |
| `account_prefs` (synced) | Truncate |
| `pending_sync` | Truncate |
| `sync_meta` | Truncate all keys EXCEPT `deviceId` |
| `device_prefs` | **Preserved** (theme, locale, debug flags) |
| `streak_local` | **Preserved** (derived; will re-derive from empty attempt history) |
| `quiz_nudge_dismissed` | **Preserved** (device UI nag-state) |

The `deviceId` survival ensures listener echo recognition stays consistent if the same user signs back in on the same install.

`hasMeaningfulProgress()` (Spec 1's other interface method) returns true if **any** of `quiz_attempts`, `lesson_progress`, or `review_state` has at least one row.

---

## 6. Triggers + push pipeline

### 6.1 Trigger inventory

| Event | Action |
|---|---|
| App cold start, user is named | Open listeners; flush any leftover `pending_sync` from a previous run |
| App foregrounded after >5 min background | Open listeners (if closed); flush queue |
| App backgrounded | Flush queue immediately (override debounce); leave listeners until OS kills |
| Drift mutation on a synced table | Enqueue `(rowId, table, op)`; arm 5s debounce |
| 5s debounce expires | Drain queue into `WriteBatch`es |
| Connectivity reconnect | Force-flush, ignore current backoff |
| Manual "Refresh" in Settings | Force-flush + force-resnapshot listeners |
| Post-purchase (RevenueCat callback) | Force-flush |
| `pushLocalToCloud()` invoked (Spec 1 flow) | Run `bootstrap/full_push.dart` |
| `pullCloudToLocal()` invoked (Spec 1 flow) | Run `bootstrap/full_pull.dart` |
| Sign-out | Flush (5s timeout) → close listeners → wipe → signout → re-anon |

### 6.2 Push pipeline

```
Drift mutation
   │
   ▼
TableObserver enqueues (table, rowId, op) into pending_sync.
On dup (same table+rowId already pending), keep oldest queuedAt,
update op to latest (upsert beats delete-then-upsert).
   │
   ▼ 5s debounce (or override event)
PushPipeline.flush():
   1. Read up to 500 pending ops in queuedAt order.
   2. For each, look up the current Drift row; resolve mapper.
   3. Build a single WriteBatch:
        upsert → batch.set(docRef, mapper.toFirestore(row), merge: true)
                 with updatedAt = FieldValue.serverTimestamp()
                      originDeviceId = sync_meta.deviceId
        delete → batch.delete(docRef)
   4. await batch.commit().
   5. Success:
        DELETE the flushed rows from pending_sync.
        sync_meta.lastSyncedAt = now()
        sync_meta.failedSince = null
        sync_meta.consecutiveFailures = 0
        emit SyncStatus.ok(...)
        If queue still has rows → schedule another flush (no debounce).
   6. Failure:
        Classify exception:
          - network / app-check / unavailable → retryable
          - permission-denied                 → non-retryable, log Crashlytics
          - quota-exceeded                    → retryable, log Crashlytics
        Increment sync_meta.consecutiveFailures.
        If failedSince == null → set failedSince = now().
        Schedule next attempt via BackoffPolicy.
        If consecutiveFailures >= 3 → emit SyncStatus.partialFailure().
        If failedSince older than 24h → emit SyncStatus.failedSince(since).
```

**Backoff policy:**

```
delays = [1s, 2s, 4s, 8s, 16s, 32s, 64s, 128s, 256s, 512s, 1024s, 1800s, 1800s, ...]
On reconnect (Connectivity stream fires online) → reset index to 0; flush now.
```

---

## 7. Pull pipeline (listeners)

### 7.1 Subscription lifecycle

```
On engine start (named user present):
  For each entry in CollectionRegistry:
    listener = firestore
        .collection('users/$uid/${entry.subcollection}')
        .snapshots(includeMetadataChanges: false)
        .listen(onSnapshot, onError);
    register listener for teardown.

On sign-out / engine stop:
  For each listener: cancel().
  Clear in-memory listener registry.
```

### 7.2 Snapshot application

For each `DocChange` in an incoming `QuerySnapshot`:

```
switch (change.type) {
  case added:
  case modified:
    incoming = mapper.fromFirestore(change.doc);
    isEcho = incoming.originDeviceId == sync_meta.deviceId
             && pending_sync still has (table, incoming.id)
                with attempts > 0;
    if (isEcho) {
      // Adopt server's serverTimestamp as canonical updatedAt.
      drift.update(incoming.id, updatedAt = incoming.updatedAt);
      // Pending row is cleared by push success path; nothing else to do.
      break;
    }
    local = drift.findById(table, incoming.id);
    if (local == null) {
      drift.insert(mapper.toDrift(incoming));
    } else if (incoming.updatedAt > local.updatedAt) {
      drift.update(mapper.toDrift(incoming));
    } // else: stale, discard
    break;

  case removed:
    if (pending_sync has upsert for (table, change.doc.id)) {
      // Our write hasn't landed yet; let it overwrite the delete.
      break;
    }
    drift.delete(table, change.doc.id);
    break;
}
```

`onError` for a listener: log Crashlytics non-fatal, mark that collection failed in `SyncStatus.partialFailure`, attempt re-subscribe after backoff. A persistent permission-denied means something is wrong with the rules — surfaces via Layer 2 banner alongside push failures.

---

## 8. Migration paths

### 8.1 `pushLocalToCloud()` (Spec 1 calls this on)

- anon-to-named link, no prior cloud data, or
- collision-fallback, cloud empty, local has data, or
- merge-prompt "Keep this device" choice.

```
emit SyncStatus.bootstrapping(direction: pushing, 0/N).
sync_meta.pending_full_push = '1'.

1. Call CloudFunctions.callable('resetCloudUserData').
   (Idempotent — re-running deletes an empty subtree as a no-op.)

2. For each entry in CollectionRegistry, in dependency order
   (assessments → fsrs_cards → quiz_attempts → lesson_progress
    → study_plan → mock_exam_attempts):
     page Drift rows in batches of 500, build WriteBatch, commit.
     Each row: updatedAt = serverTimestamp(),
               originDeviceId = sync_meta.deviceId.
     emit SyncStatus.bootstrapping(direction: pushing, k+1/N).

3. Write /users/{uid} root doc with
     preferences = account_prefs as JSON,
     lastSeenAt = serverTimestamp().

4. Open listeners (Section 7.1).

5. sync_meta.pending_full_push = absent.
   emit SyncStatus.ok(...).
```

### 8.2 `pullCloudToLocal()` (Spec 1 calls this on)

- collision-fallback, cloud has data, local empty, or
- merge-prompt "Keep my account" choice.

```
emit SyncStatus.bootstrapping(direction: pulling, 0/N).
sync_meta.pending_full_pull = '1'.

1. LocalStateWiper.wipeAll().
   (Synced tables + pending_sync + sync_meta except deviceId. Keeps
    device_prefs, streak_local, quiz_nudge_dismissed intact.)

2. Open listeners. For each collection, wait for the first
   QuerySnapshot to arrive; apply all DocChanges (always added at
   bootstrap). emit progress as collectionsReady increments.

3. Read /users/{uid} root doc → mirror preferences into account_prefs.

4. sync_meta.pending_full_pull = absent.
   sync_meta.bootstrapState = 'ready'.
   emit SyncStatus.ok(...).
```

### 8.3 Soft cap and crash recovery

Both migrations cap at 60 seconds. Beyond that, UI surfaces "Sync taking longer than expected. [Continue waiting] [Try later]." Not a failure — operation continues in background; the gate just lets the user navigate away.

If the app is killed mid-migration:

| State at kill | On next launch |
|---|---|
| `pending_full_push = '1'` | Resume from step 2 (push all rows — `set(..., merge: true)` is idempotent so re-pushing already-pushed rows is fine). |
| `pending_full_pull = '1'` | Re-run from step 2 (listeners re-snapshot; LWW handles any local writes that snuck in pre-kill). |

---

## 9. Failure handling + status surface

(Summarized from D6; full mechanics live in §6.2.)

| Layer | Trigger | UI |
|---|---|---|
| 0 | Any failure | Silent. Exponential backoff. |
| 1 | `consecutiveFailures >= 3` | Settings tab icon shows a small dot. Tap → Settings → Sync diagnostics. |
| 2 | `failedSince` older than 24h | Dismissable home-tab banner. Tap → Settings → Sync diagnostics + manual retry button. |
| 3 | n/a | Queue never truncated. |

**Settings → Sync diagnostics** (lives in Spec 8, this spec only exposes the data):

- Last sync: `lastSyncedAt` or "never".
- Pending: count of rows in `pending_sync`.
- Failing since: `failedSince` or "OK".
- Manual retry button.
- "Wipe local & re-pull" button (calls `pullCloudToLocal()` with an extra confirmation dialog) — recovery escape hatch.

---

## 10. Cloud Function — `resetCloudUserData`

Single new callable added to Spec 1's `functions/src/`:

```
options: { region: 'asia-southeast1', enforceAppCheck: true }
flow:
  1. Verify request.auth.uid present.
  2. Reject if request.auth.token.firebase.sign_in_provider == 'anonymous'.
  3. firestore.recursiveDelete('/users/{uid}/lesson_progress')
     firestore.recursiveDelete('/users/{uid}/quiz_attempts')
     firestore.recursiveDelete('/users/{uid}/fsrs_cards')
     firestore.recursiveDelete('/users/{uid}/assessments')
     firestore.recursiveDelete('/users/{uid}/study_plan')
     firestore.recursiveDelete('/users/{uid}/mock_exam_attempts')
     (Does NOT delete the /users/{uid} root doc or audit logs — identity
      and forensic trail remain intact.)
  4. writeAuditLog({ event: 'cloudDataReset', uid }).
  5. Return { resetAt: serverTimestamp }.
```

Reuses Spec 1's `_audit.ts` helper. `consumeAppCheckToken` not enabled (the operation is naturally idempotent).

---

## 11. Testing strategy

Four layers, parallels Spec 1 and Spec 2.

### Layer 1 — Dart unit tests (`test/core/sync/`)

Mocked Firestore + in-memory Drift via `NativeDatabase.memory()`.

- **Push pipeline**: 5s debounce timing; 500-op batch boundary; success-clears-queue; failure-classification table; recursive flush when queue >500; dup-enqueue coalesces on `(table, rowId)`.
- **Pull pipeline**: echo recognition via `originDeviceId`; older-snapshot discard; remove-with-pending-write keeps local row.
- **Backoff policy**: schedule produces the expected sequence; reconnect resets to zero.
- **Mappers**: round-trip Drift row → Firestore doc → Drift row for every synced table, including edge values (nulls, very long strings, all-active FSRS state shapes).
- **`LocalStateWiper.wipeAll()`**: deletes the right tables; leaves `device_prefs` / `streak_local` / `quiz_nudge_dismissed` / Spec 1's `audit_log` cache intact.
- **`SyncStatus`** transitions: idle → syncing → ok; syncing → partialFailure → ok on retry; offline → ok on reconnect; ok → failedSince after 24h fast-forward.

**Coverage target:** >85% on `lib/core/sync/`, with `engine/` and `bootstrap/` getting the most attention.

### Layer 2 — Integration tests (`integration_test/sync/`)

Firebase Emulator Suite. Real Firestore + real Drift + real isolate.

- **two-device-convergence.dart** — two clients sharing the emulator; Device A writes 5 `quiz_attempts`; Device B's Drift contains all 5 within 5s via listener.
- **offline-queue-survives-kill.dart** — go offline, write 10 attempts, kill the engine, restart, go online; queue flushes and all 10 land.
- **conflict-lww.dart** — two clients write the same FSRS card within 200ms; assert the later `serverTimestamp` wins on both clients after listener convergence.
- **echo-recognition.dart** — write locally, listener echoes back; assert local row's `updatedAt` updates to server's value and `pending_sync` row is cleared exactly once (no double-application).
- **full-push.dart** — populate local with mixed-table data; call `pushLocalToCloud()`; assert Firestore contains exactly that set; listeners open afterward; `SyncStatus.ok` emits.
- **full-pull-after-wipe.dart** — populate cloud; call `pullCloudToLocal()`; assert local matches; no leftover rows from prior local state.
- **merge-prompt-keep-this-device.dart** — populate local + cloud with overlapping + non-overlapping rows; call `resetCloudUserData` + `pushLocalToCloud()`; assert cloud is exactly local's content (Q6 acceptance test).
- **migration-resume-after-kill.dart** — start `pushLocalToCloud()`, kill mid-push; restart; assert resume completes and final cloud state is consistent.
- **24h-failure-banner.dart** — fast-forward emulator clock; configure permission-denied; assert `SyncStatus.failedSince` emits at the right moment.

### Layer 3 — Cloud Function test (`functions/test/resetCloudUserData.test.ts`)

- Rejects anonymous caller.
- Rejects missing App Check.
- Happy path: deletes all six subcollections; root doc + audit logs intact; writes `cloudDataReset` audit log.

### Layer 4 — Firestore rules test (`functions/test/rules.test.ts` additions)

The six synced subcollection paths inherit Spec 1's `isOwner(uid)` rule. Tests verify:

- Named owner CAN read+write each subcollection path.
- Different named user CANNOT.
- Anonymous CANNOT.
- The `preferences` root-doc field updates: Spec 1's `affectedKeys().hasOnly(...)` allowlist already includes `'preferences'` — verify the existing rule covers our write shape (a flat JSON object) without further changes.

### CI wiring

Extends Spec 1's three parallel jobs; no new jobs.

### Manual pre-launch verification

- [ ] Real two-device convergence on Galaxy A15 + emulator: write on phone, see it on tablet within 7s.
- [ ] Airplane-mode write → reconnect → flush verified on physical device.
- [ ] Forced 24h-failure (revoke App Check token on test device) shows banner after fast-forward.
- [ ] "Keep this device" on a populated test account leaves Firestore matching local exactly.

---

## 12. Deliverables

**Repo additions:**

- `lib/core/sync/` module per §4.1.
- Two new Drift tables (`pending_sync_table`, `sync_meta_table`); `app.db` migration to v(N+1).
- Split `app_preferences_local_table` → `device_prefs_table` + `account_prefs_table`; one-way data-migration step.
- Mappers for `quiz_attempts`, `assessments`, `fsrs_cards`, `lesson_progress`, plus stubs for `study_plan` (Spec 6) and `mock_exam_attempts` (Spec 5).
- `syncStatusProvider` exposed for Spec 8.
- `SyncCoordinator` + `LocalStateWiper` (Spec 1 interfaces) implementations.
- `functions/src/resetCloudUserData.ts` + tests.
- Background isolate spawn (Drift `DriftIsolate`); engine ports for `SyncStatus` and Drift change forwarding.
- Crashlytics non-fatals: `SyncPushFailed(category)`, `SyncListenerError(collection)`, `SyncBootstrapTimeout(direction)`.
- Tests per §11.

**Sign-off:**

- All four CI jobs green on the implementation PR.
- Manual pre-launch verification checklist completed.
- `docs/OPERATIONS.md` updated with: median foreground battery draw on Galaxy A15 to watch (>2%/hr is anomalous); sync diagnostics panel walkthrough.

---

## 13. Risks & mitigations

| Risk | Mitigation |
|---|---|
| Listener echo race with in-flight local writes corrupts row | `originDeviceId` recognition + pending_sync check; covered by `echo-recognition.dart` integration test |
| Long offline period accumulates huge `pending_sync` | Queue size bounded by user activity (≤ ~10K rows / month heavy); `WriteBatch` paging handles >500 ops cleanly; no truncation |
| Clock skew breaks LWW | Server-timestamp arbitration only; client clocks never compared |
| Cloud Function `resetCloudUserData` partially fails on a huge subtree | `firestore.recursiveDelete` handles pagination internally; `pending_full_push` flag means a retry from the client re-runs the wipe; idempotent |
| Listener subscriptions leak across sign-out | Engine teardown step explicitly cancels every listener before wipe; covered by sign-out integration test |
| Drift migration to v(N+1) breaks existing test users' progress | Pre-migration backup of `app_preferences` rows; one-way classifier preserves all keys |
| Background isolate divergence (engine + UI see different Drift state) | Use Drift's recommended `DriftIsolate.spawn` + `DatabaseConnection.delayed`; integration tests run with isolate enabled |
| App Check token unavailable at engine start | Treated as retryable failure; backoff applies; never blocks app usage on Drift |
| 24h banner over-fires on a user with legitimately spotty connectivity | Banner is dismissable; engine continues retrying silently; reconnect-resets-backoff means a brief online window flushes everything and clears `failedSince` |

---

## 14. Battery footprint

Design baseline is intentionally conservative.

- **Real-time listeners** hold a persistent socket while foregrounded; the SDK disconnects on background. **Free-lunch:** Spec 9 (Notifications/FCM) keeps the same Google Services socket open, so the listener is multiplexed onto a channel we're already paying for.
- **Debounced 5s push** coalesces session bursts into a small number of `WriteBatch`es.
- **Background isolate** is idle most of the time, woken by Drift mutations and 5s debounce.
- **Backoff with 30 min ceiling** caps wake-ups during sustained outages.

Levers explicitly NOT pulled (each was considered, each loses more UX than it saves battery):

- Open listeners only on synced-data screens — saves ~0 (FCM holds the socket).
- Lengthen push debounce to 30s — degrades multi-device convergence, the property Option B was chosen for.
- Drop listeners in favor of pull-on-launch — strict UX downgrade.

Post-launch metric in `docs/OPERATIONS.md`: **watch median foreground battery draw per hour on Galaxy A15 telemetry; >2%/hr is anomalous and worth investigating.**

---

## 15. Next step

Once approved, defer the implementation plan per the spec-brainstorming workflow (high-level specs first, plans later). The next brainstorm is Spec 4 — Review queue + quiz modes.
