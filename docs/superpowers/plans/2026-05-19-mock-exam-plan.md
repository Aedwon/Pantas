# Mock Exam Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build Spec 5's blueprint-driven timed mock exam flow with crash-safe local attempts, terminal-only sync, free-tier cooldown, and Drill follow-up links.

**Architecture:** `content.db` remains regenerable content and provides mock blueprints/questions only; `app.db` gains user-owned mock attempt rows. The mock feature lives under `lib/features/mock_exam/`, with pure domain parsing/sampling/results logic first, then Drift repositories, Riverpod controllers, sync registry activation, and Quiz/Home-facing UI routes.

**Tech Stack:** Flutter, Riverpod, GoRouter, Drift, freezed-free plain Dart models where sufficient, `uuid`, Flutter widget tests, in-memory Drift tests.

**Target spec:** `docs/superpowers/specs/2026-05-17-mock-exam-design.md`

**Date:** 2026-05-19

**Size:** L

---

## Open Questions

- Should the first UI pass include Home dashboard `MockStatusCard`, or keep the initial entry strictly on the Quiz tab until the Home dashboard layout is revisited? Tentative decision: add the reusable card widget and route hook, but avoid a broad Home redesign.
- Should `exam.scoreBands` be read now even though the current `Exam` content model has no score-band field? Tentative decision: implement default pass/borderline/fail thresholds and leave content-driven thresholds as a documented Sanity schema follow-up.
- Should discarded attempts sync as terminal rows even though discard refunds the slot? Tentative decision: yes, because Spec 5 defines discarded as terminal and Spec 3 sync expects terminal rows only; the row is useful audit/history metadata but is hidden from history scoring UI.

## External Blockers

- **Skippable: live Sanity mock blueprint content.** Author real `mockBlueprint` documents with valid `sectionsJson`, topic pools, section names, question counts, and durations.
- **Skippable: regenerated assets/seed/content.db.** Rebuild `assets/seed/content.db` from live Sanity after mock blueprint and enough question content exists; keep fixture/in-memory tests isolated meanwhile.
- **Skippable: Firebase live sync validation.** Verify terminal mock attempts push/pull against live Firestore once project credentials and App Check are available.
- **Skippable: emulator/CI credentials.** Add Firebase emulator or service-account setup before promoting live sync/rules checks into CI.
- **Skippable: Android manual QA.** Run happy path, pause/resume, process-kill resume, strict background forfeit, cooldown, and history on target Android hardware.
- **Skippable: production verification.** Validate release build with real seeded content, Firebase project aliases, and production Firestore rules before soft launch.

## File Structure

- Create `lib/features/mock_exam/mock_exam.dart` as the feature barrel.
- Create `lib/features/mock_exam/data/blueprint_section.dart`, `mock_sampler.dart`, `mock_attempt_repo.dart`, and table support in `lib/core/storage/data/tables/mock_attempts_table.dart`.
- Create `lib/features/mock_exam/domain/` for `mock_attempt.dart`, `mock_session_state.dart`, `mock_results.dart`, and use cases.
- Create `lib/features/mock_exam/application/` for availability, controller, persistence scheduler, and strict lifecycle seams.
- Create `lib/features/mock_exam/presentation/` pages/widgets under the `/quiz/mock/*` routes.
- Modify `lib/core/storage/data/app_database.dart`, generated Drift output, `lib/core/sync/engine/collection_registry.dart`, sync mapping, `lib/app/router.dart`, and Quiz/Home presentation entry points.
- Add focused tests under `test/features/mock_exam/`, sync guardrail tests under `test/core/sync/`, and tool guardrails under `test/tool/`.

## Phase 1: Audit Current Mock/Future Stubs And Sync Registry

### Step 1.1: Audit and guard existing boundaries

**Goal:** Lock down the current content/user-data/sync boundaries before adding mock code.

**Files to create/edit:**
- Create: `test/tool/mock_exam_boundary_test.dart`
- Modify: `test/core/sync/collection_registry_test.dart`
- Modify: `docs/superpowers/plans/2026-05-19-mock-exam-plan.md` only if audit uncovers a genuine plan correction.

**Tests to write first:**
- `mock exam feature does not import Sanity parser or client files`
- `sync registry keeps content database tables out of user data sync`
- `mock_exam_attempts entry starts inactive or predicate-gated until mapper lands`

**Non-obvious implementation notes:**
- Use text-based import guardrail patterns already used by `test/tool/sync_import_boundary_test.dart` and `test/tool/quiz_domain_boundary_test.dart`.
- This step is 1-2 hours and should stay build-green without production code changes unless the existing registry test needs a small expectation update.

### Step 1.2: Document current stubs and fixture constraints

**Goal:** Capture what is already parked for mock content so later implementation does not accidentally rely on live Sanity.

**Files to create/edit:**
- Modify: `docs/superpowers/plans/2026-05-19-mock-exam-plan.md`
- Optionally modify: `test/fixtures/sanity/content_sample.json` only if a mock blueprint fixture already exists but is malformed.

**Tests to write first:**
- `future content repos expose mock blueprints without app.db access` in `test/core/content/repos/future_content_repos_test.dart` if not already present.

**Non-obvious implementation notes:**
- Do not regenerate `assets/seed/content.db` in this step.
- This is a 1-hour build-green audit/documentation step.

## Phase 2: Content Schema/Repo Support For Mock Blueprints

### Step 2.1: Parse blueprint sections into typed domain rows

**Goal:** Convert `MockBlueprint.sectionsJson` into validated `BlueprintSection` objects consumed by sampler/setup UI.

**Files to create/edit:**
- Create: `lib/features/mock_exam/data/blueprint_section.dart`
- Create: `test/features/mock_exam/data/blueprint_section_test.dart`

**Tests to write first:**
- `parses valid sections json in blueprint order`
- `defaults uniform topic weights when omitted`
- `throws BlueprintParseException for malformed json`
- `throws when questionCount or suggestedMinutes is non-positive`

**Non-obvious implementation notes:**
- Accept section keys from Spec 5: `id`, `name`, `questionCount`, `suggestedMinutes`, `topicIds`, optional `topicWeights`.
- Keep parsing in `features/mock_exam` rather than `core/content`; content repos should keep storing opaque `sectionsJson`.
- This is a 1-2 hour build-green step.

### Step 2.2: Add mock blueprint provider seam

**Goal:** Expose a mock-feature provider that reads `mockBlueprintRepoProvider` without coupling UI to content internals.

**Files to create/edit:**
- Create: `lib/features/mock_exam/application/mock_blueprint_providers.dart`
- Create: `lib/features/mock_exam/mock_exam.dart`
- Create: `test/features/mock_exam/application/mock_blueprint_providers_test.dart`

**Tests to write first:**
- `mockBlueprintsForExamProvider returns parseable active blueprints`
- `provider reports invalid blueprint sections as a typed failure`

**Non-obvious implementation notes:**
- Prefer a small result object over throwing through widget build; setup page can render a retry/content-error state later.
- Do not add Sanity network calls or seed generation.
- This is a 1-2 hour build-green step.

## Phase 3: Mock Attempt Storage And Terminal Sync Predicate Support

### Step 3.1: Add `mock_attempts` user-data table

**Goal:** Persist crash-safe mock attempt state in `app.db` only.

**Files to create/edit:**
- Create: `lib/core/storage/data/tables/mock_attempts_table.dart`
- Modify: `lib/core/storage/data/app_database.dart`
- Generated: `lib/core/storage/data/app_database.g.dart`
- Create: `test/core/storage/data/mock_attempt_schema_test.dart`

**Tests to write first:**
- `app database creates mock_attempts at schema version 9`
- `mock_attempts has active attempt and history indexes`
- `content database does not include mock_attempts`

**Non-obvious implementation notes:**
- Use Spec 5 columns, including `elapsedSeconds`, `accumulatedPausedSeconds`, `pausedAtLastFlush`, JSON payload fields, score fields, timestamps, and `updatedAt`.
- Do not store content payloads beyond frozen blueprint name and sampled question IDs.
- Run `dart run build_runner build --delete-conflicting-outputs` after tests fail for missing table/codegen.
- This is a 2-3 hour build-green step.

### Step 3.2: Add mock attempt domain and repository

**Goal:** Provide CRUD/query operations for active attempts, history, cooldown, flushes, submit, discard, and stale resume.

**Files to create/edit:**
- Create: `lib/features/mock_exam/domain/mock_attempt.dart`
- Create: `lib/features/mock_exam/data/mock_attempt_repo.dart`
- Create: `test/features/mock_exam/data/mock_attempt_repo_test.dart`

**Tests to write first:**
- `insertStart creates an in-progress attempt`
- `findInProgress returns newest active attempt for user`
- `flushProgress updates elapsed flags answers current index and lastFlushedAt`
- `discard marks terminal without consuming cooldown`
- `lastCooldownAttempt ignores discarded attempts and reads completed or forfeited`
- `history returns terminal scored attempts newest first with limit`

**Non-obvious implementation notes:**
- Model status with constants/enums but persist lowercase strings: `in_progress`, `completed`, `discarded`, `forfeited`.
- `updatedAt` should change on user-visible state changes; heartbeat-only `lastFlushedAt` may update without changing sync LWW timestamp if tests require low churn.
- This is a 2-3 hour build-green step.

### Step 3.3: Activate terminal-only sync predicate and mapper

**Goal:** Register mock attempts for sync only when terminal.

**Files to create/edit:**
- Create: `lib/core/sync/mapping/mock_attempt_mapper.dart`
- Modify: `lib/core/sync/engine/collection_registry.dart`
- Modify: `lib/core/sync/engine/push_pipeline.dart` if predicates are not yet supported.
- Test: `test/core/sync/mapping/mock_attempt_mapper_test.dart`
- Test: `test/core/sync/collection_registry_test.dart`
- Test: `test/core/sync/push_pipeline_test.dart`

**Tests to write first:**
- `mock attempt mapper preserves terminal attempt fields and json snapshots`
- `registry activates mock_exam_attempts with terminal predicate`
- `push pipeline skips in-progress mock attempts`
- `push pipeline includes completed discarded and forfeited mock attempts`

**Non-obvious implementation notes:**
- Add a `bool shouldSync(Map<String, Object?> row)` or equivalent predicate on registry entries; keep default true for existing tables.
- Do not sync `content.db`, sampled question content, explanations, or blueprint records.
- This is a 2-3 hour build-green step.

## Phase 4: Mock Exam Sampler/Domain Engine

### Step 4.1: Implement deterministic section sampler

**Goal:** Sample question IDs from blueprint sections with weighted Hamilton allocation, deterministic shuffle, recency exclusion, and short-pool fallback.

**Files to create/edit:**
- Create: `lib/features/mock_exam/data/mock_sampler.dart`
- Create: `lib/features/mock_exam/domain/mock_sample.dart`
- Create: `test/features/mock_exam/data/mock_sampler_test.dart`

**Tests to write first:**
- `allocates questions by topic weights using Hamilton remainders`
- `uses uniform weights when topicWeights is absent`
- `excludes questions from last two completed mocks when possible`
- `falls back to unfiltered pool when recency filter would underfill`
- `returns partiallyFulfilled when pool is still short`
- `throws when a section has zero available questions`
- `same seed produces same sampled order`

**Non-obvious implementation notes:**
- Depend on an injected question pool reader instead of importing UI or Drift directly; repository-backed use case wires it later.
- Store output as section snapshots matching `sampledQuestionsJson`.
- This is a 2-3 hour build-green step.

### Step 4.2: Compute results and weak topics

**Goal:** Score submitted attempts, compute section accuracy/time, score bands, and top weak topics for Drill links.

**Files to create/edit:**
- Create: `lib/features/mock_exam/domain/mock_results.dart`
- Create: `lib/features/mock_exam/domain/use_cases/compute_results.dart`
- Create: `test/features/mock_exam/domain/compute_results_test.dart`

**Tests to write first:**
- `scores correct answers and treats missing answers as incorrect`
- `excludes retired or missing questions from scoreTotal`
- `computes section time from max answer atSec boundaries`
- `uses default score bands at 75 and 60 percent`
- `top weak topics require at least two sampled questions`
- `weak topic drill links use existing drill topic query shape`

**Non-obvious implementation notes:**
- Use current `Question`/`Choice` domain models from content repos; do not snapshot answer keys into attempts.
- Keep FSRS untouched; mock is summative-only.
- This is a 2-3 hour build-green step.

## Phase 5: Timed Session Lifecycle, Pause/Resume/Forfeit/Discard

### Step 5.1: Add start, submit, discard, and resume use cases

**Goal:** Orchestrate availability, blueprint resolution, sampling, attempt insertion, stale resume finalization, terminal persistence, and discard refund.

**Files to create/edit:**
- Create: `lib/features/mock_exam/domain/use_cases/start_mock.dart`
- Create: `lib/features/mock_exam/domain/use_cases/submit_mock.dart`
- Create: `lib/features/mock_exam/domain/use_cases/discard_mock.dart`
- Create: `lib/features/mock_exam/domain/use_cases/resume_mock.dart`
- Create: `test/features/mock_exam/domain/mock_lifecycle_use_cases_test.dart`

**Tests to write first:**
- `startMock inserts frozen blueprint duration and sampled questions`
- `startMock refuses unavailable free-tier slot`
- `resumeMock preserves elapsed when pausedAtLastFlush is true`
- `resumeMock catches wall clock up when attempt was active`
- `resumeMock auto-submits stale attempts as timeUp`
- `discardMock marks discarded and makes availability true`
- `submitMock persists score fields and terminal status`

**Non-obvious implementation notes:**
- Inject clock/ID generator/random seed for deterministic tests.
- Use `startedAt - accumulatedPausedSeconds` wall-clock fallback with `max(persisted, computed)` per Spec 5.
- This is a 2-3 hour build-green step.

### Step 5.2: Add session state reducer/controller

**Goal:** Manage in-memory question index, answers, flags, pause/resume, warnings, auto-submit, and strict forfeit transitions.

**Files to create/edit:**
- Create: `lib/features/mock_exam/domain/mock_session_state.dart`
- Create: `lib/features/mock_exam/application/mock_session_controller.dart`
- Create: `test/features/mock_exam/application/mock_session_controller_test.dart`

**Tests to write first:**
- `answer change records answer index and elapsed atSec`
- `flag toggle updates current question flag set`
- `pause forces paused state and resume restores in progress`
- `strict mode hides pause capability`
- `five minute and one minute warnings emit once`
- `remaining zero submits with timeUp`
- `strict background forfeit submits with strictBackground`

**Non-obvious implementation notes:**
- Keep the controller testable with a fake ticker/clock; avoid real `Timer.periodic` in unit tests.
- UI haptics/sounds are out of this domain step.
- This is a 2-3 hour build-green step.

### Step 5.3: Add persistence scheduler and strict lifecycle observer seam

**Goal:** Flush changes after mutations, heartbeat every 30 seconds, flush pause/resume immediately, and observe background strict mode.

**Files to create/edit:**
- Create: `lib/features/mock_exam/application/mock_persistence_scheduler.dart`
- Create: `lib/features/mock_exam/application/strict_mode_lifecycle.dart`
- Create: `test/features/mock_exam/application/mock_persistence_scheduler_test.dart`
- Create: `test/features/mock_exam/application/strict_mode_lifecycle_test.dart`

**Tests to write first:**
- `answer mutations debounce into one flush`
- `heartbeat flushes elapsed every thirty seconds`
- `pause and resume flush immediately`
- `strict lifecycle ignores non-strict attempts`
- `strict lifecycle forfeits only after more than five seconds backgrounded`

**Non-obvious implementation notes:**
- Scheduler writes through `MockAttemptRepo.flushProgress`; controller should not know Drift details.
- Lifecycle class should wrap `WidgetsBindingObserver` but expose a pure test seam for state changes.
- This is a 2-3 hour build-green step.

## Phase 6: Free-Tier Cooldown And Entitlement Seam

### Step 6.1: Add entitlement hook and availability provider

**Goal:** Enforce one free mock per 14 days per exam while allowing Pro to bypass cooldown.

**Files to create/edit:**
- Create: `lib/features/mock_exam/application/mock_availability_provider.dart`
- Create: `lib/features/mock_exam/domain/mock_availability.dart`
- Modify: `lib/core/storage/data/repos/app_preferences_repository.dart` only if strict-mode account pref helpers are needed.
- Create: `test/features/mock_exam/application/mock_availability_provider_test.dart`

**Tests to write first:**
- `free user with no prior terminal attempt is available`
- `free user with in-progress attempt must resume`
- `free user before fourteen days sees cooldown remaining`
- `free user after fourteen days is available`
- `discarded attempt does not start cooldown`
- `pro user is always available unless in-progress must resume`

**Non-obvious implementation notes:**
- Add a minimal local `MockEntitlementSnapshot`/provider seam; do not initialize RevenueCat, purchase flows, paywall UI, or Spec 7 routes.
- Cooldown is derived from latest completed/forfeited submit timestamp, never stored.
- This is a 1-2 hour build-green step.

### Step 6.2: Add strict mock mode preference seam

**Goal:** Persist/read the Settings-level strict mode value needed by mock start without building full Settings UI.

**Files to create/edit:**
- Create: `lib/features/mock_exam/application/mock_exam_preferences.dart`
- Create: `test/features/mock_exam/application/mock_exam_preferences_test.dart`

**Tests to write first:**
- `strict mock mode defaults to false`
- `strict mock mode persists in account preferences`
- `startMock snapshots strict mode onto the attempt`

**Non-obvious implementation notes:**
- Store a simple `strict_mock_mode` account preference key so Spec 8 can surface the toggle later.
- Do not build Settings screen beyond this data hook.
- This is a 1-2 hour build-green step.

## Phase 7: Mock Exam UI/Routing

### Step 7.1: Add mock routes and setup/chooser surfaces

**Goal:** Let users enter the mock flow from Quiz, choose a blueprint when needed, and start a session.

**Files to create/edit:**
- Modify: `lib/app/router.dart`
- Modify: `lib/features/quiz/presentation/quiz_tab_home.dart`
- Create: `lib/features/mock_exam/presentation/pages/mock_setup_page.dart`
- Create: `lib/features/mock_exam/presentation/widgets/blueprint_picker_sheet.dart`
- Create: `lib/features/mock_exam/presentation/widgets/mock_quiz_tab_tile.dart`
- Test: `test/features/mock_exam/presentation/mock_setup_page_test.dart`
- Test: `test/app/router_redirect_test.dart`

**Tests to write first:**
- `router accepts /quiz/mock/setup`
- `setup page shows blueprint duration section count and start button`
- `multiple blueprints show picker sheet`
- `quiz tab mock tile shows ready cooldown and in-progress states`

**Non-obvious implementation notes:**
- Use existing UI components and theme; no vendor/tool attribution strings.
- Keep first screen usable app UI, not a marketing page.
- This is a 2-3 hour build-green step.

### Step 7.2: Add session page and navigator sheet

**Goal:** Render timed mock questions with countdown, answer selection, flags, free navigation, pause, submit, and system-back confirmation.

**Files to create/edit:**
- Create: `lib/features/mock_exam/presentation/pages/mock_session_page.dart`
- Create: `lib/features/mock_exam/presentation/widgets/question_navigator_sheet.dart`
- Test: `test/features/mock_exam/presentation/mock_session_page_test.dart`
- Test: `test/features/mock_exam/presentation/question_navigator_sheet_test.dart`

**Tests to write first:**
- `session page renders current question and countdown`
- `pause button is hidden in strict mode`
- `answer tap updates selected state`
- `flag toggle changes navigator pill state`
- `question navigator jumps to tapped question`
- `next blank and next flagged choose expected targets`
- `system back shows leave mock confirmation`

**Non-obvious implementation notes:**
- Reuse `PortableTextRenderer` and existing answer tile patterns.
- Intercept back; leaving the screen should not pause or submit.
- This is a 2-3 hour build-green step.

### Step 7.3: Add resume sheet and history page

**Goal:** Surface in-progress attempts on launch/Quiz entry and show paginated terminal history.

**Files to create/edit:**
- Modify: `lib/app/app.dart` or an app bootstrap widget seam for first-frame intercept.
- Create: `lib/features/mock_exam/presentation/widgets/mock_resume_sheet.dart`
- Create: `lib/features/mock_exam/presentation/pages/mock_history_page.dart`
- Test: `test/features/mock_exam/presentation/mock_resume_sheet_test.dart`
- Test: `test/features/mock_exam/presentation/mock_history_page_test.dart`

**Tests to write first:**
- `resume sheet shows blueprint elapsed and remaining`
- `resume action opens session route`
- `discard action calls discard use case`
- `stale attempt auto-finalizes without rendering sheet`
- `history page shows newest ten attempts and see all state`

**Non-obvious implementation notes:**
- If launch intercept is risky, first wire the resume sheet through Quiz tab and leave app-first-frame intercept as a small follow-up within this step.
- History excludes in-progress rows and can hide discarded rows unless "See all" is expanded.
- This is a 2-3 hour build-green step.

## Phase 8: Results Screen With Weak-Topic Drill Deep Links

### Step 8.1: Add results page free/pro rendering seam

**Goal:** Show score band, section table, weak topics, Drill CTAs, Pro review seam, strict/forfeit labels, and saved/cooldown footer.

**Files to create/edit:**
- Create: `lib/features/mock_exam/presentation/pages/mock_results_page.dart`
- Create: `lib/features/mock_exam/presentation/widgets/mock_status_card.dart`
- Test: `test/features/mock_exam/presentation/mock_results_page_test.dart`
- Test: `test/features/mock_exam/presentation/mock_status_card_test.dart`

**Tests to write first:**
- `free results show score sections weak topics and pro review card`
- `pro results show per-question review section`
- `forfeited results show strict forfeit header`
- `weak topic practice button routes to existing drill route`
- `status card renders ready cooldown and in-progress states`

**Non-obvious implementation notes:**
- Drill route should match Spec 4's accepted route/query shape; update router tests if route currently uses `topicId` rather than `topic`.
- Do not build paywall UI; Pro card can route to a placeholder entitlement/paywall seam if one already exists, otherwise remain inert with tested copy.
- This is a 2-3 hour build-green step.

### Step 8.2: Add final polish states without scope creep

**Goal:** Cover warnings, partial fulfillment copy, saving failure banner, and no-overlap responsive widget constraints.

**Files to create/edit:**
- Modify: mock presentation files from Phase 7/8.
- Test: relevant existing mock widget tests.

**Tests to write first:**
- `partial fulfillment setup copy shows actual and expected counts`
- `one minute warning banner appears once`
- `saving failure banner appears after repeated flush failures`

**Non-obvious implementation notes:**
- Keep animation/haptic hooks lightweight and optional; do not add Lottie or audio assets unless already present.
- This is a 1-2 hour build-green step.

## Phase 9: Docs/Guardrails/Final Verification

### Step 9.1: Add docs and guardrails

**Goal:** Document parked live work and enforce no content sync/no attribution/no layer leaks.

**Files to create/edit:**
- Modify: `docs/superpowers/plans/2026-05-19-mock-exam-plan.md`
- Modify: `test/tool/content_docs_test.dart` or create `test/tool/mock_exam_docs_test.dart`
- Modify: `test/tool/sync_import_boundary_test.dart`
- Create/modify attribution guardrail test if existing pattern is present.

**Tests to write first:**
- `mock exam docs list live Sanity and Firebase blockers`
- `sync guardrail never registers content database tables`
- `mock exam files contain no tool model vendor attribution strings`

**Non-obvious implementation notes:**
- Use the exact external blocker wording from this plan in docs tests where practical.
- This is a 1-2 hour build-green step.

### Step 9.2: Run final verification and commit completion state

**Goal:** Prove the implementation is green locally and report any blocked external checks honestly.

**Files to create/edit:**
- No planned source edits unless verification exposes a failing test requiring a TDD fix.

**Tests to write first:**
- If verification fails, write or tighten the focused failing test that reproduces the issue before fixing production code.

**Non-obvious implementation notes:**
- Run `flutter test`.
- Run `flutter analyze`.
- Run any new backend/tooling tests introduced by the implementation.
- Run existing guardrails, including layering and attribution checks.
- Do not run live Sanity/Firebase/production checks without credentials; report them as parked blockers.
- This is a 2-3 hour build-green step plus any required fixes.
