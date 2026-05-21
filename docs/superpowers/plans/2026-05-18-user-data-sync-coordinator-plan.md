# User-data SyncCoordinator Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the Spec 1 sync seams with a testable user-data sync module that queues `app.db` user-state changes, maps supported rows to Firestore documents, bootstraps sign-in merge push/pull flows, and exposes sync status for later Settings diagnostics.

**Architecture:** `lib/core/sync/` owns Firestore-facing gateways, mapper contracts, queue draining, bootstrap orchestration, status/backoff primitives, and Riverpod providers. `app.db` remains the only user-data database; `content.db` and Sanity-backed tables are never imported by sync code.

**Tech Stack:** Flutter, Riverpod, Drift, Cloud Firestore/Functions adapters behind fakeable interfaces, Node 20 Firebase Functions, static Firestore rules tests, Flutter tests with `NativeDatabase.memory()`.

**Target spec:** `docs/superpowers/specs/2026-05-16-user-data-sync-coordinator-design.md`

**Date:** 2026-05-18

**Size:** L

---

## Open Questions

- The current app only has device/onboarding preferences (`selected_exam_id`, `passed_age_gate`) in `app_preferences_local_table`; there are no reminder-time or strict-mock account preferences yet. Tentative choice: split the table now and route existing keys to `device_prefs`; create `account_prefs` empty and mapper-ready for Spec 5/6/8 keys.
- The spec requires Drift background-isolate execution, but this repo does not yet expose a reusable `DriftIsolate` opener around the SQLCipher app database. Tentative choice: implement the sync engine against injected database/gateway interfaces first, keep all heavy work off widgets, and add the isolate runner seam/documentation in Phase 8 without changing the mapper/queue contracts.

## External Blockers

- **Skippable: live Firebase project validation.** Confirm `cse-cet-reviewer-dev` and `cse-cet-reviewer-prod` exist, are in `asia-southeast1`, and have Auth, Firestore, Functions, App Check, Crashlytics, Remote Config, Messaging, and Storage enabled.
- **Skippable: Firestore rules deployment.** Deploy `firestore.rules` to dev/prod with `firebase deploy --only firestore:rules` after project aliases and credentials exist.
- **Skippable: Firestore index deployment.** Validate whether collection-group or composite indexes are needed after emulator tests are added; deploy any generated `firestore.indexes.json` entries.
- **Skippable: callable deployment.** Deploy `resetCloudUserData` to both Firebase projects with `firebase deploy --only functions:resetCloudUserData`.
- **Skippable: App Check enforcement validation.** Register dev debug tokens, configure Play Integrity for prod, turn on Firestore/Functions App Check enforcement, and verify callable rejection without valid App Check.
- **Skippable: emulator/CI credentials.** Add Firebase CLI auth or service-account setup for rules/functions emulator tests in CI if live emulator runs become required.
- **Skippable: production backfill/manual verification.** Before soft launch, run one real-device named-account flow: write local progress, sign in, keep device, reinstall, sign in again, keep account, and confirm progress restores.
- **Skippable: Functions dependency install.** Run `npm install` in `functions/` if package-lock or emulator test dependencies are added and network access is available.
- **Skippable: generated Firebase options.** Regenerate `firebase_options_dev.dart`/`firebase_options_prod.dart` only after live project access is available; local sync unit tests use fake gateways.

## File Structure

- Create `lib/core/sync/sync.dart` as the public barrel.
- Create `lib/core/sync/sync_status.dart`, `backoff_policy.dart`, and `clock.dart` for pure status/retry primitives.
- Create `lib/core/sync/device_id.dart` and `lib/core/sync/local_state_wiper.dart` to implement Spec 1's `LocalStateWiper` seam.
- Create `lib/core/sync/engine/pending_queue.dart`, `push_pipeline.dart`, `pull_pipeline.dart`, `collection_registry.dart`, and `sync_engine.dart` around fakeable gateways.
- Create `lib/core/sync/firestore/firestore_gateway.dart` with a production adapter that is the only sync file importing `cloud_firestore`.
- Create `lib/core/sync/bootstrap/full_push.dart` and `full_pull.dart` for Spec 1 merge decisions.
- Create `lib/core/sync/mapping/` with row/document mappers for attempts, assessment results, FSRS cards, lesson progress, account preferences, and forward-compatible study-plan/mock entries.
- Modify `lib/core/storage/data/app_database.dart` plus table files to add `pending_sync`, `sync_meta`, `device_prefs`, and `account_prefs`.
- Modify `lib/core/storage/data/repos/app_preferences_repository.dart` to keep existing app behavior on device prefs.
- Modify `lib/core/auth/providers.dart` or app bootstrap wiring only after local sync providers are green.
- Modify `functions/src/index.ts` and add `functions/src/resetCloudUserData.ts`.
- Modify or add static tests under `test/core/sync/`, `test/core/storage/data/`, `test/tool/`, and `functions/test/`.

## Phase 1: Sync Database/User-data Schema Audit + Local Sync Metadata

### Step 1.1: Add pending sync and sync meta tables

**Goal:** Persist a durable queue and local sync metadata in `app.db`.

**Files:**
- Create: `lib/core/storage/data/tables/pending_sync_table.dart`
- Create: `lib/core/storage/data/tables/sync_meta_table.dart`
- Modify: `lib/core/storage/data/app_database.dart`
- Test: `test/core/storage/data/sync_schema_test.dart`

**Test cases to write first:**
- `app database creates pending_sync and sync_meta tables at schema version 5`
- `pending_sync coalesces tableType and rowId through a unique index`
- `sync_meta stores one value per key`
- `content database schema does not include pending_sync or sync_meta`

**Implementation notes:**
- Add a unique index over `(tableType, rowId)` and an index over `queuedAt`.
- Keep queue rows generic: `id`, `tableType`, `rowId`, `op`, `queuedAt`, `attempts`, `lastError`, `lastAttemptAt`.
- Migration from schema 4 to 5 only creates new user-data tables; it must not touch `content.db`.
- Run: `flutter test test/core/storage/data/sync_schema_test.dart`
- Commit: `feat(sync): add sync metadata schema`

### Step 1.2: Split local and account preferences

**Goal:** Preserve existing onboarding preferences as device-local data while adding an empty synced account preference table.

**Files:**
- Create: `lib/core/storage/data/tables/device_prefs_table.dart`
- Create: `lib/core/storage/data/tables/account_prefs_table.dart`
- Modify: `lib/core/storage/data/app_database.dart`
- Modify: `lib/core/storage/data/repos/app_preferences_repository.dart`
- Test: `test/core/storage/data/repos/app_preferences_repository_test.dart`
- Test: `test/core/storage/data/preference_migration_test.dart`

**Test cases to write first:**
- `selected exam id is stored in device_prefs`
- `age gate flag is stored in device_prefs`
- `migration routes legacy app_preferences_local rows to device_prefs`
- `account_prefs starts empty when only onboarding preferences exist`

**Implementation notes:**
- Existing keys `selected_exam_id` and `passed_age_gate` are device-local because they drive install/onboarding state, not account study preferences.
- Keep the legacy table available during migration only if Drift cannot drop it safely in one release; repository reads must use `devicePrefs`.
- Bump schema once for all Phase 1 table changes if Step 1.1 and 1.2 are implemented together.
- Run: `flutter test test/core/storage/data/repos/app_preferences_repository_test.dart test/core/storage/data/preference_migration_test.dart`
- Commit: `feat(sync): split local and account preferences`

### Step 1.3: Add queue repository primitives

**Goal:** Provide tested enqueue, coalesce, drain, success, and failure operations over `pending_sync`.

**Files:**
- Create: `lib/core/sync/engine/pending_queue.dart`
- Test: `test/core/sync/pending_queue_test.dart`

**Test cases to write first:**
- `enqueue inserts a new upsert operation`
- `enqueue coalesces duplicate table and row while preserving oldest queuedAt`
- `delete followed by upsert leaves an upsert operation`
- `drain returns rows in FIFO order with a configurable limit`
- `markFailure increments attempts and records last error`
- `markSuccess deletes flushed rows`

**Implementation notes:**
- Use a fake clock so FIFO/coalescing tests are deterministic.
- Model operation names as `upsert` and `delete` constants, not ad hoc strings in callers.
- Do not wire repository mutations to auto-enqueue yet; pipeline tests will enqueue explicitly.
- Run: `flutter test test/core/sync/pending_queue_test.dart`
- Commit: `feat(sync): add pending queue repository`

## Phase 2: Mapper Layer for Existing Synced Tables

### Step 2.1: Add mapper contracts and collection registry

**Goal:** Define the single source of truth for synced tables and their Firestore paths without adding network behavior.

**Files:**
- Create: `lib/core/sync/mapping/sync_mapper.dart`
- Create: `lib/core/sync/engine/collection_registry.dart`
- Test: `test/core/sync/collection_registry_test.dart`

**Test cases to write first:**
- `registry includes only app.db user-data collections`
- `registry excludes content database tables`
- `registry marks study_plan and mock_exam_attempts as future inactive entries`
- `each active entry has a table type subcollection and mapper`

**Implementation notes:**
- Active collections for this repo state: `quiz_attempts`, `assessments`, `fsrs_cards`, `lesson_progress`, and `preferences`.
- Stub future entries as inactive descriptors so Specs 5/6 add only table + mapper activation.
- Keep mapper inputs as Drift rows/maps so unit tests do not need Firestore SDK.
- Run: `flutter test test/core/sync/collection_registry_test.dart`
- Commit: `feat(sync): add collection registry`

### Step 2.2: Map quiz attempts and assessment results

**Goal:** Round-trip attempts and assessments between Drift rows and Firestore document maps.

**Files:**
- Create: `lib/core/sync/mapping/attempt_mapper.dart`
- Create: `lib/core/sync/mapping/assessment_mapper.dart`
- Test: `test/core/sync/mapping/attempt_mapper_test.dart`
- Test: `test/core/sync/mapping/assessment_mapper_test.dart`

**Test cases to write first:**
- `attempt mapper includes id examId startedAt completedAt itemsJson schemaVersion and originDeviceId`
- `attempt mapper round trips nullable completedAt`
- `assessment mapper uses examId as stable document id`
- `assessment mapper preserves topicScoresJson`

**Implementation notes:**
- Do not include `content.db` question or topic payloads; store only user-state row fields.
- Mappers receive `updatedAt` and `originDeviceId` from the pipeline so server timestamp injection stays centralized.
- Use ISO8601 strings or `DateTime` values in pure mapper tests; Firestore `Timestamp` conversion belongs in the gateway adapter.
- Run: `flutter test test/core/sync/mapping/attempt_mapper_test.dart test/core/sync/mapping/assessment_mapper_test.dart`
- Commit: `feat(sync): add attempt and assessment mappers`

### Step 2.3: Map FSRS cards, lesson progress, and account preferences

**Goal:** Cover the remaining currently available synced rows.

**Files:**
- Create: `lib/core/sync/mapping/fsrs_card_mapper.dart`
- Create: `lib/core/sync/mapping/lesson_progress_mapper.dart`
- Create: `lib/core/sync/mapping/preferences_mapper.dart`
- Test: `test/core/sync/mapping/fsrs_card_mapper_test.dart`
- Test: `test/core/sync/mapping/lesson_progress_mapper_test.dart`
- Test: `test/core/sync/mapping/preferences_mapper_test.dart`

**Test cases to write first:**
- `fsrs mapper preserves scheduling fields and dirty state is local only`
- `lesson progress mapper uses lessonId as document id`
- `preferences mapper converts account_prefs rows to root preferences object`
- `preferences mapper does not include device_prefs keys`

**Implementation notes:**
- `dirty`, `syncState`, `syncAttempts`, and `lastSyncError` are local-only legacy fields and must not be written to Firestore.
- Root-doc preferences are handled as a special registry entry with no subcollection listener.
- Run: `flutter test test/core/sync/mapping`
- Commit: `feat(sync): add remaining Firestore mappers`

## Phase 3: Firestore Client/Gateway + Retry/Status Primitives

### Step 3.1: Add sync status and backoff policy

**Goal:** Model status transitions and retry timing independently from Firestore.

**Files:**
- Create: `lib/core/sync/sync_status.dart`
- Create: `lib/core/sync/engine/backoff_policy.dart`
- Test: `test/core/sync/sync_status_test.dart`
- Test: `test/core/sync/backoff_policy_test.dart`

**Test cases to write first:**
- `backoff emits 1s through 1024s then caps at 30 minutes`
- `reconnect reset restarts backoff at 1s`
- `failedSince is emitted after 24 hours of continuous failure`
- `partialFailure is emitted after three consecutive failures`

**Implementation notes:**
- Use plain sealed classes, not generated code.
- Keep user-facing copy out of status types; Spec 8 owns diagnostics UI.
- Run: `flutter test test/core/sync/sync_status_test.dart test/core/sync/backoff_policy_test.dart`
- Commit: `feat(sync): add sync status primitives`

### Step 3.2: Add fakeable Firestore and Functions gateways

**Goal:** Centralize Firestore/Functions SDK imports behind interfaces that unit tests can fake.

**Files:**
- Create: `lib/core/sync/firestore/firestore_gateway.dart`
- Create: `lib/core/sync/firestore/functions_gateway.dart`
- Test: `test/core/sync/firestore_gateway_contract_test.dart`
- Test: `test/tool/sync_import_boundary_test.dart`

**Test cases to write first:**
- `fake gateway records batched set delete and root preference writes`
- `fake functions gateway records resetCloudUserData calls`
- `only firestore gateway files import cloud_firestore or cloud_functions`

**Implementation notes:**
- Production adapter should expose `commitBatch`, `listenCollection`, `readRootPreferences`, `writeRootPreferences`, and `hasMeaningfulCloudData`.
- Do not call live Firebase in tests.
- Run: `flutter test test/core/sync/firestore_gateway_contract_test.dart test/tool/sync_import_boundary_test.dart`
- Commit: `feat(sync): add Firestore gateway seam`

### Step 3.3: Add push pipeline queue flushing

**Goal:** Drain pending rows into ≤500-op gateway batches with retry metadata.

**Files:**
- Create: `lib/core/sync/engine/push_pipeline.dart`
- Test: `test/core/sync/push_pipeline_test.dart`

**Test cases to write first:**
- `flush writes queued upserts and deletes in one batch`
- `flush splits more than 500 operations into multiple batches`
- `successful flush clears pending rows and resets failure metadata`
- `retryable failure increments consecutiveFailures and keeps queue rows`
- `named user required and anonymous user leaves queue untouched`

**Implementation notes:**
- Resolve current Drift rows at flush time; a queued upsert whose row disappeared becomes a delete.
- Treat anonymous users as no-op per Spec 3 target spec, even though the earlier roadmap summary mentioned anonymous sync.
- Status stream starts with `idle`, emits `syncing`, then `ok` or failure state.
- Run: `flutter test test/core/sync/push_pipeline_test.dart`
- Commit: `feat(sync): add push pipeline`

## Phase 4: Bootstrap Push/Pull Flows for Spec 1 Sign-in Merge

### Step 4.1: Implement full push bootstrap

**Goal:** Support Spec 1's "Keep this device" path by resetting cloud data and pushing all current local synced rows.

**Files:**
- Create: `lib/core/sync/bootstrap/full_push.dart`
- Modify: `lib/core/sync/engine/sync_engine.dart`
- Test: `test/core/sync/bootstrap/full_push_test.dart`

**Test cases to write first:**
- `full push calls resetCloudUserData before writing rows`
- `full push writes all active registry collections in deterministic order`
- `full push writes account preferences to root user document`
- `full push clears pending_full_push marker after success`
- `full push leaves pending_full_push marker after retryable failure`

**Implementation notes:**
- Use `set(..., merge: true)` semantics in the gateway adapter.
- Do not write Sanity/content rows or streak/nudge/device prefs.
- Page rows in 500-op chunks, same as push pipeline.
- Run: `flutter test test/core/sync/bootstrap/full_push_test.dart`
- Commit: `feat(sync): implement bootstrap full push`

### Step 4.2: Implement full pull bootstrap

**Goal:** Support Spec 1's "Keep my account" path by wiping synced local state and applying first cloud snapshots.

**Files:**
- Create: `lib/core/sync/bootstrap/full_pull.dart`
- Modify: `lib/core/sync/engine/sync_engine.dart`
- Test: `test/core/sync/bootstrap/full_pull_test.dart`

**Test cases to write first:**
- `full pull wipes local synced state before applying cloud rows`
- `full pull applies first snapshot from each active collection`
- `full pull mirrors root preferences into account_prefs`
- `full pull preserves device prefs streak and quiz nudge rows`
- `full pull clears pending_full_pull marker after success`

**Implementation notes:**
- Use the same row-apply methods as the listener pipeline so conflict behavior is not duplicated.
- Bootstrap has a 60-second timeout surface in status only; UI controls land in later specs.
- Run: `flutter test test/core/sync/bootstrap/full_pull_test.dart`
- Commit: `feat(sync): implement bootstrap full pull`

### Step 4.3: Implement SyncCoordinator seam

**Goal:** Wire Spec 1's `SyncCoordinator.pushLocalToCloud()` and `pullCloudToLocal()` calls to the engine.

**Files:**
- Create: `lib/core/sync/sync_coordinator.dart`
- Modify: `lib/core/auth/providers.dart`
- Test: `test/core/sync/sync_coordinator_test.dart`
- Test: `test/core/auth/providers_test.dart`

**Test cases to write first:**
- `pushLocalToCloud delegates to full push`
- `pullCloudToLocal delegates to full pull`
- `auth repository can be overridden with sync coordinator-backed wiper`
- `default providers remain override-friendly in tests`

**Implementation notes:**
- If Spec 1 currently only defined `LocalStateWiper`, introduce `SyncCoordinator` in `lib/core/sync/` without changing auth repository constructor behavior until provider wiring is tested.
- Keep merge-prompt UI out of scope.
- Run: `flutter test test/core/sync/sync_coordinator_test.dart test/core/auth/providers_test.dart`
- Commit: `feat(sync): wire sync coordinator seam`

## Phase 5: Realtime Listener Coordinator + Conflict/LWW Handling

### Step 5.1: Add pull pipeline row application

**Goal:** Apply incoming cloud changes with server-timestamp last-writer-wins behavior.

**Files:**
- Create: `lib/core/sync/engine/pull_pipeline.dart`
- Test: `test/core/sync/pull_pipeline_test.dart`

**Test cases to write first:**
- `incoming row inserts when no local row exists`
- `incoming row with newer updatedAt replaces local row`
- `incoming row with older updatedAt is discarded`
- `own echo updates canonical updatedAt only`
- `remote delete is ignored when a pending local upsert exists`

**Implementation notes:**
- Existing tables lack `updatedAt`; add local sync timestamp columns only where LWW needs local comparison, or store per-row timestamps in `sync_meta` keyed by table/id if schema churn is lower.
- Echo recognition uses `originDeviceId` plus pending queue state.
- Run: `flutter test test/core/sync/pull_pipeline_test.dart`
- Commit: `fix(sync): handle last-write-wins conflicts`

### Step 5.2: Add listener lifecycle coordinator

**Goal:** Start, stop, and resubscribe collection listeners for named users.

**Files:**
- Modify: `lib/core/sync/engine/sync_engine.dart`
- Modify: `lib/core/sync/engine/pull_pipeline.dart`
- Test: `test/core/sync/sync_engine_listener_test.dart`

**Test cases to write first:**
- `start opens one listener per active subcollection for named users`
- `start is a no-op for anonymous users`
- `stop cancels every listener`
- `listener error emits partialFailure and schedules resubscribe`
- `manual refresh restarts listeners and force flushes queue`

**Implementation notes:**
- Preferences root doc is refreshed through explicit reads, not a subcollection listener.
- Listener cancellation must be idempotent for sign-out and cold-start retries.
- Run: `flutter test test/core/sync/sync_engine_listener_test.dart`
- Commit: `feat(sync): add listener coordinator`

## Phase 6: LocalStateWiper Implementation + Meaningful-progress Predicate

### Step 6.1: Implement local state wipe scope

**Goal:** Delete only synced user-data rows while preserving device-local state.

**Files:**
- Create: `lib/core/sync/local_state_wiper.dart`
- Test: `test/core/sync/local_state_wiper_test.dart`

**Test cases to write first:**
- `wipeAll deletes attempts assessments review state lesson progress account prefs and pending sync`
- `wipeAll preserves device prefs streak local and quiz nudge dismissed`
- `wipeAll preserves sync_meta deviceId and removes other sync keys`
- `wipeAll ignores future tables that are not present yet`

**Implementation notes:**
- Do not delete content tables or `content.db`.
- Keep `deviceId` stable across sign-out for echo recognition.
- Run: `flutter test test/core/sync/local_state_wiper_test.dart`
- Commit: `feat(sync): implement local state wiper`

### Step 6.2: Implement meaningful progress checks

**Goal:** Make Spec 1's collision fallback predicate reflect actual local progress.

**Files:**
- Modify: `lib/core/sync/local_state_wiper.dart`
- Test: `test/core/sync/meaningful_progress_test.dart`

**Test cases to write first:**
- `hasMeaningfulProgress is false for only preferences age gate and selected exam`
- `hasMeaningfulProgress is true for quiz attempts`
- `hasMeaningfulProgress is true for lesson progress`
- `hasMeaningfulProgress is true for review state`
- `hasMeaningfulProgress ignores content database rows`

**Implementation notes:**
- Use existence queries with `LIMIT 1`; do not hydrate domain models.
- Assessment-only data is not included by the spec predicate unless a later product decision changes it.
- Run: `flutter test test/core/sync/meaningful_progress_test.dart`
- Commit: `feat(sync): add meaningful progress predicate`

### Step 6.3: Add cloud meaningful-progress gateway

**Goal:** Let Spec 1 collision fallback check named-account cloud data through a fakeable Firestore gateway.

**Files:**
- Create: `lib/core/sync/cloud_progress_gateway.dart`
- Modify: `lib/core/auth/providers.dart`
- Test: `test/core/sync/cloud_progress_gateway_test.dart`

**Test cases to write first:**
- `cloud progress is false when all meaningful collections are empty`
- `cloud progress is true when quiz_attempts has a document`
- `cloud progress is true when lesson_progress has a document`
- `cloud progress is true when fsrs_cards has a document`
- `anonymous uid checks are rejected before Firestore call`

**Implementation notes:**
- Use count/limit queries in production adapter; fake tests should not depend on Firebase emulator.
- Keep this separate from full sync status because auth collision flow only needs a boolean.
- Run: `flutter test test/core/sync/cloud_progress_gateway_test.dart`
- Commit: `feat(sync): add cloud progress gateway`

## Phase 7: Callable/Function Support + Rules/Tests

### Step 7.1: Add resetCloudUserData callable

**Goal:** Make cloud wipe atomic for "Keep this device" bootstrap.

**Files:**
- Create: `functions/src/resetCloudUserData.ts`
- Modify: `functions/src/index.ts`
- Test: `functions/test/static.test.mjs`

**Test cases to write first:**
- `index exports resetCloudUserData`
- `resetCloudUserData enforces App Check without consumeAppCheckToken`
- `resetCloudUserData rejects anonymous callers`
- `resetCloudUserData deletes the six user-data subcollections`
- `resetCloudUserData writes cloudDataReset audit log`

**Implementation notes:**
- Reuse `_audit.ts` named-user assertion/helper patterns.
- Do not delete `/users/{uid}` root doc or `/audit_logs`.
- Use Admin SDK recursive delete where available; otherwise page deletes under each fixed subcollection.
- Run: `npm test --prefix functions`
- Commit: `feat(functions): add cloud user data reset callable`

### Step 7.2: Extend rules/static tests for sync paths

**Goal:** Guard owner-only named-user access for every sync collection.

**Files:**
- Modify: `firestore.rules`
- Modify: `functions/test/static.test.mjs`
- Test: `test/tool/firebase_rules_layout_test.dart`

**Test cases to write first:**
- `rules include all six synced subcollections under users uid`
- `rules keep anonymous users denied through isNamedUser`
- `rules allow preferences updates only on root doc allowed keys`
- `audit logs remain server-only`

**Implementation notes:**
- Current rules already list the six paths; tests should lock that in rather than loosen rules.
- Live rules-unit tests are skippable until emulator credentials/dependencies exist.
- Run: `flutter test test/tool/firebase_rules_layout_test.dart && npm test --prefix functions`
- Commit: `test(sync): cover Firestore sync rules`

## Phase 8: Provider Wiring, Diagnostics Seams, CI/Docs

### Step 8.1: Add sync Riverpod providers and diagnostics surface

**Goal:** Expose a singleton engine, status stream, and manual retry entrypoint for later Settings UI.

**Files:**
- Create: `lib/core/sync/providers.dart`
- Create: `lib/core/sync/sync.dart`
- Modify: `lib/app/bootstrap.dart`
- Test: `test/core/sync/providers_test.dart`

**Test cases to write first:**
- `syncStatusProvider emits idle from fake engine`
- `manual retry provider calls force flush`
- `providers are override-friendly for widget tests`
- `app bootstrap does not start sync for anonymous users`

**Implementation notes:**
- Do not add Settings UI, dashboard UI, notification, paywall, or progress screens.
- Add comments only where provider construction is non-obvious.
- Run: `flutter test test/core/sync/providers_test.dart test/app/app_boot_test.dart`
- Commit: `feat(sync): add provider surface`

### Step 8.2: Document Firebase sync setup and external blockers

**Goal:** Capture manual deployment/validation steps without requiring live project access in code.

**Files:**
- Modify: `docs/OPERATIONS.md` or create if absent
- Test: `test/tool/firebase_setup_docs_test.dart`

**Test cases to write first:**
- `Firebase setup docs mention resetCloudUserData deployment`
- `Firebase setup docs mention App Check enforcement validation`
- `Firebase setup docs mention Firestore rules deployment`
- `Firebase setup docs mention real-device push pull verification`

**Implementation notes:**
- Keep docs factual and operational; do not add attribution text.
- Mention that `content.db` is regenerable content and out of user-data sync scope.
- Run: `flutter test test/tool/firebase_setup_docs_test.dart`
- Commit: `docs(sync): document Firebase sync setup`

### Step 8.3: Add CI/static guardrails for sync scope

**Goal:** Prevent accidental content sync or broad Firebase SDK imports.

**Files:**
- Modify: `tool/check_layering.dart`
- Modify: `.github/workflows/ci.yml`
- Test: `test/tool/check_layering_test.dart` if present, otherwise `test/tool/sync_import_boundary_test.dart`

**Test cases to write first:**
- `sync code does not import lib/core/content`
- `content code does not import lib/core/sync`
- `only sync firestore adapters import cloud_firestore`
- `CI runs sync import boundary tests`

**Implementation notes:**
- Keep checks local and deterministic; do not require network or Firebase project access.
- If no existing layering test exists, keep the new test under `test/tool/`.
- Run: `flutter test test/tool/sync_import_boundary_test.dart`
- Commit: `test(sync): add sync scope guardrails`

## Final Verification

- Run: `dart format --output=none --set-exit-if-changed .`
- Run: `flutter analyze`
- Run: `flutter test`
- Run: `npm test --prefix functions`
- Run: `dart run tool/check_layering.dart`
- Run: `dart run tool/check_no_ai_attribution.dart`
- Fix failures and commit fixes with the smallest conventional commit message that describes the correction.

## Self-review

- Spec coverage: Phases 1-8 cover local metadata, mappers, Firestore gateway, push/pull bootstrap, realtime listener coordination, LWW conflicts, LocalStateWiper, reset callable, provider/status seams, docs, and guardrails. `content.db` is explicitly excluded in registry, wiper, docs, and static tests.
- External blockers: live Firebase validation, rules/index/function deployment, App Check enforcement, emulator/CI credentials, and production manual verification are listed as skippable so local fakeable work can proceed.
- TDD integrity: every step names tests to write first, the expected focused command, and a commit.
- Scope drift check: the plan does not add paywall UI, settings UI, notifications, progress dashboard, mock exam flows, or Sanity/content sync.
- Placeholder scan: no unfinished placeholder markers or unspecified "write tests for this" placeholders remain.
