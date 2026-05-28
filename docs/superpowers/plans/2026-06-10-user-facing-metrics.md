# User-Facing Metrics And Personality Fingerprint Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Pantas user-facing metrics pipeline from existing raw tables: Signals -> Atoms -> Archetypes -> Wrapped artifacts, then wire the Spec 9 and Spec 11 amendments.

**Architecture:** `lib/features/metrics/` owns all derived metric computation. Signals are live, pure aggregators over existing tables; atoms consume signals for Home chips; archetypes and Wrapped artifacts persist derived cache rows in local-only Drift tables that are not synced. `lib/features/wrapped/` owns trigger composition, reveal/share surfaces, PNG rendering, and notification stream payloads.

**Tech Stack:** Flutter, Riverpod, Drift, GoRouter, in-memory Drift tests, widget tests, deterministic template copy, on-device `RepaintBoundary` PNG capture.

**Locked implementation decisions:** FSRS weak -> strong mastery crossing is `stability >= 14.0` days. Multiple streak/mastery crossings on the same local day batch into a single Wrapped trigger notification/reveal payload. No new instrumentation events are added; all signals derive from existing tables.

---

## File Structure

- Create `lib/features/metrics/metrics.dart` as the feature barrel.
- Create `lib/features/metrics/domain/` for shared keys, windows, thresholds, contracts, and typed signal output models.
- Create `lib/features/metrics/signals/` for the 13 signal implementations plus JSON parsers for attempt/mock payloads.
- Create `lib/features/metrics/atoms/` for atom selection and Home chip widgets.
- Create `lib/features/metrics/archetypes/` for deterministic matchers, synthesis templates, resolver, and cache repository.
- Create `lib/features/metrics/data/` for `user_metrics_archetypes_local` and `user_metrics_artifacts_local` Drift tables and local repositories.
- Create `lib/features/metrics/providers/` for the public Riverpod contracts consumed by Home, Progress, and Wrapped.
- Create `lib/features/wrapped/` for artifact trigger rules, payload composition, reveal pages, PNG renderer, share flow, and trigger stream.
- Modify `lib/core/storage/data/app_database.dart` and generated Drift output for local-only cache tables.
- Modify `lib/features/assessment/presentation/assessment_home_tab.dart` only to render the new atom chip; do not migrate Home.
- Modify notification routing under `lib/features/notifications/` only to subscribe to `wrappedTriggerStream`; do not duplicate trigger logic.
- Fill `lib/features/progress/` by consuming metrics providers; do not add a separate progress cache.

## Phase 1: Signals

### Task 1.1: Core Metrics Contracts And Windows

**Files:**
- Create: `lib/features/metrics/domain/metric_signal.dart`
- Create: `lib/features/metrics/domain/metrics_window.dart`
- Create: `lib/features/metrics/domain/signal_key.dart`
- Create: `lib/features/metrics/domain/metrics_thresholds.dart`
- Create: `lib/features/metrics/signals/metrics_window_resolver.dart`
- Test: `test/features/metrics/domain/metrics_window_resolver_test.dart`

**Scope boundaries:** Define contracts only. Do not query Drift, build UI, or create cache tables in this task.

- [ ] Write failing tests for rolling-30d, all-time, prep-window, and threshold behavior.
- [ ] Implement `MetricsWindow`, `SignalKey`, `Signal<T>`, `SignalResult<T>`, and `MetricsWindowResolver`.
- [ ] Bake in data thresholds: rolling-30d >= 7 sessions, prep-window >= 14 sessions, all-time >= 1 session.
- [ ] Verify: `flutter test test/features/metrics/domain/metrics_window_resolver_test.dart`.

### Task 1.2: Signal Output Models And Payload Parsers

**Files:**
- Create: `lib/features/metrics/domain/signal_outputs.dart`
- Create: `lib/features/metrics/signals/attempt_item_reader.dart`
- Create: `lib/features/metrics/signals/mock_payload_reader.dart`
- Test: `test/features/metrics/signals/attempt_item_reader_test.dart`
- Test: `test/features/metrics/signals/mock_payload_reader_test.dart`

**Scope boundaries:** Parse existing JSON payloads and define immutable value objects. Do not compute full signals yet.

- [ ] Write failing tests for `Attempt.itemsJson`, mock sampled question order, mock answers with `atSec`, flags, and section results.
- [ ] Implement typed outputs for all 13 signals: `DayHourHistogram`, `DurationDistribution`, `StreakPattern`, `LatencyDistribution`, `PacingProfile`, `StaminaDelta`, `FlagRevisitRatio`, `SubjectAccuracySpeed`, `PressureDelta`, `CalibrationCurve`, `WorkflowRatio`, `RetentionCurve`, and `CoveragePct`.
- [ ] Implement parser helpers that tolerate missing optional fields by returning empty parsed sections, not throwing in signal code.
- [ ] Verify: `flutter test test/features/metrics/signals/attempt_item_reader_test.dart test/features/metrics/signals/mock_payload_reader_test.dart`.

### Task 1.3: Time And Consistency Signals

**Files:**
- Create: `lib/features/metrics/signals/time_of_day_signal.dart`
- Create: `lib/features/metrics/signals/session_shape_signal.dart`
- Create: `lib/features/metrics/signals/consistency_signal.dart`
- Test: `test/features/metrics/signals/time_of_day_signal_test.dart`
- Test: `test/features/metrics/signals/session_shape_signal_test.dart`
- Test: `test/features/metrics/signals/consistency_signal_test.dart`

**Scope boundaries:** Implement T1, T2, T3 only from `quiz_sessions`, `mock_attempts`, and `streak_local`. No atoms or archetypes.

- [ ] Write failing in-memory Drift tests for empty data, below threshold, just-above threshold, and correct aggregation.
- [ ] Implement T1 peak hour accuracy/count, T2 session duration distribution, and T3 current streak plus weekday histogram.
- [ ] Verify: `flutter test test/features/metrics/signals/time_of_day_signal_test.dart test/features/metrics/signals/session_shape_signal_test.dart test/features/metrics/signals/consistency_signal_test.dart`.

### Task 1.4: Performance And Strategy Signals

**Files:**
- Create: `lib/features/metrics/signals/per_question_speed_signal.dart`
- Create: `lib/features/metrics/signals/mock_pacing_signal.dart`
- Create: `lib/features/metrics/signals/mock_stamina_signal.dart`
- Create: `lib/features/metrics/signals/flag_revisit_signal.dart`
- Test: matching files under `test/features/metrics/signals/`

**Scope boundaries:** Implement P1, P2, P4, S1. Do not add new mock instrumentation.

- [ ] Write failing tests for latency averages, mock section pacing, first-half vs last-half accuracy, and flagged-question answer timing.
- [ ] Implement P1 from `attempts.itemsJson.responseMs`.
- [ ] Implement P2 from `mock_attempts.elapsedSeconds`, `totalTimeSeconds`, duration, and section result time snapshots.
- [ ] Implement P4 from sampled question order plus answer correctness reconstructed from existing mock answer payload and content question choices.
- [ ] Implement S1 from `flagsJson` and answer timestamps.
- [ ] Verify: `flutter test test/features/metrics/signals/per_question_speed_signal_test.dart test/features/metrics/signals/mock_pacing_signal_test.dart test/features/metrics/signals/mock_stamina_signal_test.dart test/features/metrics/signals/flag_revisit_signal_test.dart`.

### Task 1.5: Subject, Pressure, Workflow, Retention, Coverage Signals

**Files:**
- Create: `lib/features/metrics/signals/subject_affinity_signal.dart`
- Create: `lib/features/metrics/signals/test_mode_delta_signal.dart`
- Create: `lib/features/metrics/signals/difficulty_calibration_signal.dart`
- Create: `lib/features/metrics/signals/read_then_quiz_signal.dart`
- Create: `lib/features/metrics/signals/retention_shape_signal.dart`
- Create: `lib/features/metrics/signals/coverage_breadth_signal.dart`
- Test: matching files under `test/features/metrics/signals/`

**Scope boundaries:** Implement U1, X1, X2, D1, D2, D3 from existing content and user tables. No cache writes.

- [ ] Write failing tests for each signal using synthetic content/topic/subject rows and user rows.
- [ ] Implement U1 by joining attempts to questions/topics/subjects.
- [ ] Implement X1 by comparing practice and mock accuracy on matched topics.
- [ ] Implement X2 by correlating response time, correctness, and `review_state.difficulty`.
- [ ] Implement D1 by comparing lesson `readAt` with first attempt time on that topic.
- [ ] Implement D2 from `review_state.stability` and lapses.
- [ ] Implement D3 from lesson progress plus topic catalog.
- [ ] Verify: `flutter test test/features/metrics/signals/subject_affinity_signal_test.dart test/features/metrics/signals/test_mode_delta_signal_test.dart test/features/metrics/signals/difficulty_calibration_signal_test.dart test/features/metrics/signals/read_then_quiz_signal_test.dart test/features/metrics/signals/retention_shape_signal_test.dart test/features/metrics/signals/coverage_breadth_signal_test.dart`.

### Task 1.6: Public Signal Providers

**Files:**
- Create: `lib/features/metrics/providers/metrics_signal_providers.dart`
- Create: `lib/features/metrics/metrics.dart`
- Test: `test/features/metrics/providers/metrics_signal_providers_test.dart`

**Scope boundaries:** Expose `metricsSignalProvider(signal, window, examId)` and registry wiring. Do not expose raw Drift internals.

- [ ] Write failing provider tests that override `appDatabaseProvider` and request representative signals.
- [ ] Implement a registry that maps every `SignalKey` to its signal class.
- [ ] Verify all 13 measured signals exist; no additions or substitutions.
- [ ] Verify: `flutter test test/features/metrics/providers/metrics_signal_providers_test.dart`.

## Phase 2: Atoms

### Task 2.1: Atom Domain And Deterministic Rotation

**Files:**
- Create: `lib/features/metrics/atoms/atom.dart`
- Create: `lib/features/metrics/atoms/atom_rotation.dart`
- Test: `test/features/metrics/atoms/atom_rotation_test.dart`

**Scope boundaries:** Selection mechanics only. Do not render widgets or query real signals.

- [ ] Write failing tests proving `(localDate, userId)` rotation is stable and avoids repeating when alternatives exist.
- [ ] Implement `AtomChip`, `ProDepth`, `Atom`, and deterministic rotation over the seven atom keys.
- [ ] Verify: `flutter test test/features/metrics/atoms/atom_rotation_test.dart`.

### Task 2.2: Seven Home Atom Selectors

**Files:**
- Create: one atom file per catalog entry under `lib/features/metrics/atoms/`
- Test: matching files under `test/features/metrics/atoms/`

**Scope boundaries:** Implement exactly T1, T2, T3, P1, U1, D2, D3 atoms. P2, P4, S1, X1, X2, D1 remain archetype/Wrapped only.

- [ ] Write failing tests for chip copy and null fallback for each atom.
- [ ] Implement deterministic copy such as `Sharpest at 9pm`, `Avg 8-min sits`, and `Day 18 streak`.
- [ ] Keep Pro depth data attached but unrendered for Free users.
- [ ] Verify: `flutter test test/features/metrics/atoms`.

### Task 2.3: Home Atom Provider And Assessment Home Integration

**Files:**
- Create: `lib/features/metrics/providers/home_atom_provider.dart`
- Create: `lib/features/metrics/atoms/home_atom_chip.dart`
- Modify: `lib/features/assessment/presentation/assessment_home_tab.dart`
- Test: `test/features/metrics/providers/home_atom_provider_test.dart`
- Test: `test/features/metrics/atoms/home_atom_chip_test.dart`
- Test: `test/features/assessment/presentation/assessment_home_tab_test.dart`

**Scope boundaries:** Add the chip to the existing Home tab only. Do not migrate Home to a new feature.

- [ ] Write failing provider and widget tests for atom fallback and day-1 no-chip state.
- [ ] Implement `homeAtomProvider(examId)` using auth/user id and atom rotation.
- [ ] Render `HomeAtomChip` in the existing assessment Home tab without disrupting the existing assessment/study-plan card.
- [ ] Verify: `flutter test test/features/metrics/providers/home_atom_provider_test.dart test/features/metrics/atoms/home_atom_chip_test.dart test/features/assessment/presentation/assessment_home_tab_test.dart`.

## Phase 3: Archetypes

### Task 3.1: Local-Only Archetype Cache Table

**Files:**
- Create: `lib/core/storage/data/tables/user_metrics_archetypes_local_table.dart`
- Modify: `lib/core/storage/data/app_database.dart`
- Generated: `lib/core/storage/data/app_database.g.dart`
- Test: `test/core/storage/data/user_metrics_archetype_schema_test.dart`
- Test: `test/core/sync/collection_registry_test.dart`

**Scope boundaries:** Persistence only. Do not modify Spec 3 sync collections.

- [ ] Write failing tests that schema version increases, the table exists, primary key is `(userId, examId, window, archetypeId)`, and sync registry omits it.
- [ ] Add Drift table with `matchScore`, `synthesizedCopy`, `computedAt`, and `validUntil`.
- [ ] Run Drift codegen.
- [ ] Verify: `flutter test test/core/storage/data/user_metrics_archetype_schema_test.dart test/core/sync/collection_registry_test.dart`.

### Task 3.2: Archetype Catalog, Matching, And Resolution

**Files:**
- Create: `lib/features/metrics/archetypes/archetype.dart`
- Create: `lib/features/metrics/archetypes/archetype_catalog.dart`
- Create: `lib/features/metrics/archetypes/archetype_resolver.dart`
- Test: `test/features/metrics/archetypes/archetype_catalog_test.dart`
- Test: `test/features/metrics/archetypes/archetype_resolver_test.dart`

**Scope boundaries:** Pure matching over supplied signal outputs. No Drift writes.

- [ ] Write failing tests for all 14 archetypes: high-score fixture, low-score fixture, and required signal null behavior.
- [ ] Implement category priority: Pressure-Mode > Pace > Subject > Study Habit > Strategy.
- [ ] Implement alphabetical tie-break inside the winning category.
- [ ] Verify: `flutter test test/features/metrics/archetypes`.

### Task 3.3: Deterministic Synthesis And Archetype Provider

**Files:**
- Create: `lib/features/metrics/archetypes/archetype_templates.dart`
- Create: `lib/features/metrics/data/user_metrics_archetype_repository.dart`
- Create: `lib/features/metrics/providers/current_archetype_provider.dart`
- Test: `test/features/metrics/archetypes/archetype_templates_test.dart`
- Test: `test/features/metrics/data/user_metrics_archetype_repository_test.dart`
- Test: `test/features/metrics/providers/current_archetype_provider_test.dart`

**Scope boundaries:** Cache archetype match/copy only. Do not cache signals or artifacts.

- [ ] Write failing tests for deterministic copy, `validUntil` reuse, expired recompute, and null when no archetype resolves.
- [ ] Implement template substitution with no LLM/runtime model.
- [ ] Implement recompute triggers as callable invalidation APIs: mock completion, every 10 quiz sessions, first-load-of-day, and expired read.
- [ ] Verify: `flutter test test/features/metrics/archetypes/archetype_templates_test.dart test/features/metrics/data/user_metrics_archetype_repository_test.dart test/features/metrics/providers/current_archetype_provider_test.dart`.

## Phase 4: Artifacts

### Task 4.1: Local-Only Artifact Cache Table

**Files:**
- Create: `lib/core/storage/data/tables/user_metrics_artifacts_local_table.dart`
- Modify: `lib/core/storage/data/app_database.dart`
- Generated: `lib/core/storage/data/app_database.g.dart`
- Test: `test/core/storage/data/user_metrics_artifact_schema_test.dart`
- Test: `test/core/sync/collection_registry_test.dart`

**Scope boundaries:** Persistence only. Do not sync artifact history.

- [ ] Write failing tests for schema, primary key `(userId, examId, artifactId)`, `shareId`, `payloadJson`, `sharedAt`, and sync omission.
- [ ] Add the Drift table and migration.
- [ ] Verify: `flutter test test/core/storage/data/user_metrics_artifact_schema_test.dart test/core/sync/collection_registry_test.dart`.

### Task 4.2: Wrapped Payload, Trigger Stream, And Batching

**Files:**
- Create: `lib/features/wrapped/domain/wrapped_payload.dart`
- Create: `lib/features/wrapped/domain/wrapped_trigger_event.dart`
- Create: `lib/features/wrapped/application/wrapped_trigger_bus.dart`
- Create: `lib/features/wrapped/application/wrapped_batcher.dart`
- Test: `test/features/wrapped/application/wrapped_batcher_test.dart`
- Test: `test/features/wrapped/application/wrapped_trigger_bus_test.dart`

**Scope boundaries:** Stream and batching primitives only. No artifact-specific trigger logic yet.

- [ ] Write failing tests for local-day batching of multiple mastery crossings and streak+mastery combinations.
- [ ] Implement `wrappedTriggerStream` with replay-free event delivery.
- [ ] Implement batching rule: multiple streak/mastery events on the same local day produce one batched payload; post-mock and post-exam remain standalone.
- [ ] Verify: `flutter test test/features/wrapped/application/wrapped_batcher_test.dart test/features/wrapped/application/wrapped_trigger_bus_test.dart`.

### Task 4.3: Four Artifact Trigger Rules

**Files:**
- Create: `lib/features/wrapped/artifacts/post_mock_recap_artifact.dart`
- Create: `lib/features/wrapped/artifacts/streak_milestone_artifact.dart`
- Create: `lib/features/wrapped/artifacts/mastery_crossing_artifact.dart`
- Create: `lib/features/wrapped/artifacts/post_exam_debrief_artifact.dart`
- Test: matching files under `test/features/wrapped/artifacts/`

**Scope boundaries:** Trigger decisions only. Composition/rendering comes later.

- [ ] Write failing tests for first mock, new PB, non-PB no-fire, streak thresholds 7/30/100/365 only, weak->strong threshold `14.0`, and exactly-once post-exam.
- [ ] Implement `shouldFire` methods that never duplicate notification routing.
- [ ] Hook emission seams into `SubmitMock`, `StreakEvaluator`, `ReviewStateRepository.upsert` or a wrapper, and daily cold-start tick with minimal changes.
- [ ] Verify: `flutter test test/features/wrapped/artifacts`.

### Task 4.4: Payload Composition And Repository

**Files:**
- Create: `lib/features/wrapped/artifacts/wrapped_artifact.dart`
- Create: `lib/features/wrapped/data/user_metrics_artifact_repository.dart`
- Create: `lib/features/wrapped/application/wrapped_composer.dart`
- Test: `test/features/wrapped/application/wrapped_composer_test.dart`
- Test: `test/features/wrapped/data/user_metrics_artifact_repository_test.dart`

**Scope boundaries:** Compose and persist payload JSON. Do not render PNG yet.

- [ ] Write failing tests for slide order, null-signal slide skipping, minimum two slides, and no-fire when archetype cannot resolve.
- [ ] Implement four artifact composers with deterministic titles and slide copy from `WrappedPayload`.
- [ ] Generate `shareId` locally and persist full payload JSON before reveal/notification routing.
- [ ] Verify: `flutter test test/features/wrapped/application/wrapped_composer_test.dart test/features/wrapped/data/user_metrics_artifact_repository_test.dart`.

### Task 4.5: Reveal Pages, PNG Renderer, Share Flow, Privacy

**Files:**
- Create: `lib/features/wrapped/presentation/wrapped_reveal_page.dart`
- Create: `lib/features/wrapped/presentation/share_privacy_sheet.dart`
- Create: `lib/features/wrapped/rendering/wrapped_share_card.dart`
- Create: `lib/features/wrapped/rendering/wrapped_png_renderer.dart`
- Modify: `lib/app/router.dart`
- Test: `test/features/wrapped/presentation/wrapped_reveal_page_test.dart`
- Test: `test/features/wrapped/rendering/wrapped_png_renderer_test.dart`
- Test: `test/features/wrapped/application/wrapped_share_flow_test.dart`

**Scope boundaries:** Single 9:16 PNG share format only. Landing page remains a stub URL.

- [ ] Write failing tests for route load from local artifact cache, privacy toggles default off, PNG dimensions 1080x1920, watermark text, deep-link text/QR placeholder, and analytics consent gating.
- [ ] Implement `WrappedRevealPage` with full-screen slides and share CTA.
- [ ] Implement off-screen `RepaintBoundary` rendering and cached PNG generation.
- [ ] Implement local `sharedAt` writes regardless of consent; emit `wrapped_shared`/`wrapped_revealed` only through Spec 10 analytics consent gate.
- [ ] Verify: `flutter test test/features/wrapped/presentation/wrapped_reveal_page_test.dart test/features/wrapped/rendering/wrapped_png_renderer_test.dart test/features/wrapped/application/wrapped_share_flow_test.dart`.

## Phase 5: Spec 9 Notifications Amendment Integration

### Task 5.1: Wrapped Notification Source Routing

**Files:**
- Modify: `lib/features/notifications/domain/notification_payload.dart`
- Modify: `lib/features/notifications/domain/notification_body_composer.dart`
- Create: `lib/features/notifications/application/wrapped_trigger_notification_router.dart`
- Modify: `lib/features/notifications/application/notifications_providers.dart`
- Test: `test/features/notifications/application/wrapped_trigger_notification_router_test.dart`
- Test: `test/features/notifications/domain/notification_payload_test.dart`

**Scope boundaries:** Subscribe to `wrappedTriggerStream` only. Never recompute trigger conditions in notifications.

- [ ] Write failing tests for source identifiers, foreground reveal routing, background push payload route `/wrapped/<artifactId>`, `shareId`, quiet-hours behavior, and post-exam quiet-hours bypass.
- [ ] Implement router using existing foreground/background dispatch and existing push consent gate.
- [ ] Pull push title/body from `WrappedPayload.title` and first slide content.
- [ ] Verify: `flutter test test/features/notifications/application/wrapped_trigger_notification_router_test.dart test/features/notifications/domain/notification_payload_test.dart`.

## Phase 6: Spec 11 Progress Amendment Integration

### Task 6.1: Progress Dashboard Data Contracts

**Files:**
- Create: `lib/features/progress/domain/progress_panel.dart`
- Create: `lib/features/progress/application/progress_providers.dart`
- Test: `test/features/progress/application/progress_providers_test.dart`

**Scope boundaries:** Progress reads metrics providers only. Do not add `progress_cache`.

- [ ] Write failing tests proving current-state panels read rolling-30d, retrospective panels read prep-window, and achievement panels read all-time.
- [ ] Implement providers for archetype block, atom-equivalent signal stats, analytical panels, and past Wrapped artifact lookup.
- [ ] Add a guardrail test that `lib/features/progress/` does not declare or use `progress_cache`.
- [ ] Verify: `flutter test test/features/progress/application/progress_providers_test.dart test/tool/progress_boundary_test.dart`.

### Task 6.2: Progress UI With Content-Type Entitlement

**Files:**
- Create: `lib/features/progress/presentation/progress_page.dart`
- Create: `lib/features/progress/presentation/paywall_teaser_panel.dart`
- Modify: `lib/app/router.dart`
- Test: `test/features/progress/presentation/progress_page_test.dart`
- Test: `test/features/progress/presentation/paywall_teaser_panel_test.dart`

**Scope boundaries:** Free users see identity content fully and analytical dashboard teasers. Phase 2 history/evolution views remain deferred.

- [ ] Write failing widget tests for Free and Pro rendering.
- [ ] Implement `PaywallTeaserPanel` for trend lines, weakness narrative, score-impact analysis, and per-mock comparison.
- [ ] Implement Pro full analytical panel placeholders backed by metrics providers, not local progress aggregation.
- [ ] Verify: `flutter test test/features/progress/presentation/progress_page_test.dart test/features/progress/presentation/paywall_teaser_panel_test.dart`.

## Phase 7: Cross-Cutting Guardrails And Verification

### Task 7.1: Boundary, Privacy, And Regression Guardrails

**Files:**
- Create: `test/tool/metrics_boundary_test.dart`
- Create: `test/tool/wrapped_boundary_test.dart`
- Create: `test/tool/progress_boundary_test.dart`
- Modify: `test/tool/sync_import_boundary_test.dart`

**Scope boundaries:** Guardrails only. No production changes except fixing violations.

- [ ] Write tests that enforce: no new instrumentation event definitions except consent-gated `wrapped_shared`/`wrapped_revealed`; metrics cache tables are absent from Spec 3 sync registry; Progress consumes metrics providers; notifications consume `wrappedTriggerStream`.
- [ ] Verify: `flutter test test/tool/metrics_boundary_test.dart test/tool/wrapped_boundary_test.dart test/tool/progress_boundary_test.dart test/tool/sync_import_boundary_test.dart`.

### Task 7.2: Full Verification

**Files:**
- No production files unless a verification failure identifies a bug.

**Scope boundaries:** Verify the completed feature set.

- [ ] Run: `dart format lib/features/metrics lib/features/wrapped lib/features/progress lib/features/notifications lib/features/assessment lib/core/storage test/features/metrics test/features/wrapped test/features/progress test/features/notifications test/tool`.
- [ ] Run: `dart run build_runner build --delete-conflicting-outputs`.
- [ ] Run: `flutter analyze`.
- [ ] Run: `flutter test`.
- [ ] Manually verify that no files on `codex-spec-3-user-data-sync` were modified and no cache table is registered for sync.

