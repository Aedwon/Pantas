# Study Plan Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build Spec 6's compute-on-read Study Plan with persisted plan preferences, pacing/domain logic, a `/plan` surface, and guardrails that preserve the `app.db` user-data and `content.db` content boundary.

**Architecture:** The plan is computed from account preferences, the selected exam, topic/question volume, assessment mastery, review state, and mock attempt history. Only user-owned preferences and acknowledgement timestamps persist in `app.db`; `content.db` remains regenerable content and is never synced by Spec 6.

**Tech Stack:** Flutter, Riverpod, GoRouter, Drift, Firestore gateway seam tests, Flutter widget tests, pure Dart domain tests, existing tool guardrails.

**Target spec:** `docs/superpowers/specs/2026-05-18-study-plan-design.md`

**Roadmap anchor:** `docs/superpowers/specs/2026-05-16-mvp-roadmap-design.md` Spec 6 - Study Plan

**Date:** 2026-05-21

**Size:** L

---

## Open Questions

- Should Spec 8 later expose exam-date and intensity editing only from Settings, or should `/plan` also include edit affordances? Tentative decision for Spec 6: implement domain/provider seams and the `/plan` route, but leave the Settings entry UI to Spec 8.
- Should the Home dashboard receive a plan card in this pass even though the current Home tab is still the assessment surface? Tentative decision: add the reusable card widget and route wiring, then avoid a broad Home redesign.
- Should Firestore native plan-pref writes ship now or remain behind a gateway seam until live Firebase validation unblocks? Tentative decision: build the repository interface and local Drift implementation first; add a Firestore gateway adapter only where existing auth/Firebase seams make it testable without live credentials.

## External Blockers

- **Skippable: live Sanity content.** Add real `exam.targetMastery`, representative topic volume, and tagged question/lesson content in Sanity before production validation.
- **Skippable: regenerated assets/seed/content.db.** Rebuild `assets/seed/content.db` from live Sanity after `targetMastery` and enough topic/question volume exist; isolated tests use fixtures and in-memory databases until then.
- **Skippable: Firebase live sync validation.** Validate plan preference partial-field writes against live Firestore once project credentials, App Check, and auth flows are available.
- **Skippable: emulator/CI credentials.** Add Firebase emulator or service-account setup before promoting plan-pref gateway checks into CI.
- **Skippable: Android manual QA.** Verify `/plan`, exam-date edge states, intensity copy, rest days, and navigation on target Android hardware.
- **Skippable: production verification.** Validate a release build with real seeded content, production Firebase config, and production Firestore rules before soft launch.

## File Structure

- Create `lib/features/study_plan/study_plan.dart` as the feature barrel.
- Create `lib/features/study_plan/domain/` for `plan_prefs.dart`, `pace_curve.dart`, `daily_sizer.dart`, `plan_view.dart`, `coach_copy.dart`, and `use_cases/compute_plan_view.dart`.
- Create `lib/features/study_plan/data/plan_prefs_repository.dart` for `app.db`-backed account preference reads/writes.
- Create `lib/features/study_plan/application/study_plan_providers.dart` for Riverpod seams over selected exam, content volume, review state, assessment state, mock state, and plan preferences.
- Create `lib/features/study_plan/presentation/` widgets and pages for `PlanPage`, `HomePlanCard`, `TodayInset`, `UpcomingDayChip`, `MockWeekCard`, `CollapsedPlanSection`, and `PlanUpdatedChip`.
- Modify `lib/core/storage/data/repos/app_preferences_repository.dart` only if shared account-pref helpers are needed; do not add plan rows to `content.db`.
- Modify `lib/app/router.dart` to add `/plan` as a full-screen non-shell route.
- Modify `lib/features/quiz/presentation/quiz_tab_home.dart` only to let Today's Session surface the Study Plan daily recommendation without changing quiz picker ownership.
- Add tests under `test/features/study_plan/`, storage tests under `test/core/storage/`, widget tests under `test/features/study_plan/presentation/`, and tool guardrails under `test/tool/`.

## Phase 1: Boundaries, Preferences, And Guardrails

### Step 1.1: Add Study Plan boundary guardrails

**Goal:** Lock down the data and layering boundaries before adding Study Plan production code.

**Files to create/edit:**
- Create: `test/tool/study_plan_boundary_test.dart`
- Modify: `test/tool/sync_import_boundary_test.dart`

**Tests to write first:**
- `study plan domain files do not import Flutter Firestore Firebase Dio or Drift`
- `study plan data files do not import content database internals directly`
- `sync module does not import study plan presentation or content database`
- `content database does not contain study plan preference tables`

**Non-obvious implementation notes:**
- Follow text-scanning patterns from `test/tool/quiz_domain_boundary_test.dart` and `test/tool/mock_exam_boundary_test.dart`.
- This step is 1-2 hours and build-green with guardrail-only code.

### Step 1.2: Persist plan preferences in user-data account prefs

**Goal:** Store `examDate`, `examDateIsProvisional`, `intensityPreset`, and rebalance acknowledgement metadata in `app.db` user-data preferences without adding persisted plan-day rows.

**Files to create/edit:**
- Create: `lib/features/study_plan/domain/plan_prefs.dart`
- Create: `lib/features/study_plan/data/plan_prefs_repository.dart`
- Create: `lib/features/study_plan/study_plan.dart`
- Modify: `lib/core/storage/data/repos/app_preferences_repository.dart` only if shared account-pref accessors are cleaner than raw Drift queries.
- Test: `test/features/study_plan/data/plan_prefs_repository_test.dart`
- Test: `test/features/study_plan/domain/plan_prefs_test.dart`

**Tests to write first:**
- `returns defaults when plan prefs are missing`
- `saves exact exam date as non-provisional`
- `saves provisional exam date separately from exact date`
- `rejects an exam date before today`
- `saves and reads light standard and intense intensity presets`
- `marks plan updated chip as pending until acknowledged`

**Non-obvious implementation notes:**
- Use `account_prefs`, not `device_prefs`, because plan preferences should follow a named user once Firestore plan-pref writes are enabled.
- Store dates as ISO-8601 calendar strings in UTC-free `yyyy-MM-dd` form to avoid timezone drift around Manila midnight.
- Persist enum values as lowercase strings: `light`, `standard`, `intense`.
- This step is 2-3 hours and build-green.

## Phase 2: Pure Domain Pacing And Daily Sizing

### Step 2.1: Implement pace curve and pace status

**Goal:** Compute the expected mastery for a date and classify actual mastery as behind, on pace, or ahead with a 5% tolerance band.

**Files to create/edit:**
- Create: `lib/features/study_plan/domain/pace_curve.dart`
- Test: `test/features/study_plan/domain/pace_curve_test.dart`

**Tests to write first:**
- `expected mastery equals start mastery on plan start date`
- `expected mastery equals target mastery on exam date`
- `expected mastery clamps when today is before start or after exam`
- `actual mastery within five percentage points is on pace`
- `actual mastery below tolerance is behind`
- `actual mastery above tolerance is ahead`
- `mastery already above target remains ahead without negative workload`

**Non-obvious implementation notes:**
- Keep this file dependency-free and deterministic with `DateTime` calendar-day normalization.
- Default `targetMastery` to `0.75` until Sanity content exposes a richer field through `Exam`.
- This step is 1-2 hours and build-green.

### Step 2.2: Implement daily sizer with intensity, floor, cap, and rest days

**Goal:** Convert content volume, days remaining, pace gap, and intensity into a stable daily action size.

**Files to create/edit:**
- Create: `lib/features/study_plan/domain/daily_sizer.dart`
- Test: `test/features/study_plan/domain/daily_sizer_test.dart`

**Tests to write first:**
- `standard intensity uses one rest day per week`
- `light intensity uses two rest days per week`
- `intense intensity uses no rest days`
- `per day count respects floor on active days`
- `per day count respects one point five times baseline cap`
- `behind pace increases active day load without exceeding cap`
- `all topics at target produces review only sizing`

**Non-obvious implementation notes:**
- Use question count as the v1 workload proxy because content minutes are incomplete and live Sanity is blocked.
- Keep smoothing week-local; do not persist computed day rows.
- This step is 1-2 hours and build-green.

### Step 2.3: Generate plan view from computed inputs

**Goal:** Produce `PlanView` containing Today, three upcoming days, nearest mock week, collapsed past/future summaries, and pace metadata.

**Files to create/edit:**
- Create: `lib/features/study_plan/domain/plan_view.dart`
- Create: `lib/features/study_plan/domain/coach_copy.dart`
- Create: `lib/features/study_plan/domain/use_cases/compute_plan_view.dart`
- Test: `test/features/study_plan/domain/compute_plan_view_test.dart`

**Tests to write first:**
- `today action includes review count lesson recommendation drill recommendation and CTA target`
- `upcoming contains exactly three future days by default`
- `nearest mock appears when a mock week is within two weeks`
- `missing diagnostic uses start mastery fallback and diagnostic prompt copy`
- `exam date too close produces compressed-plan warning`
- `all topics at target shifts today to FSRS review mode`
- `coach copy never uses scolding phrases`

**Non-obvious implementation notes:**
- Topic targeting is a preview only; actual quiz content stays owned by Spec 4 pickers.
- Keep Free/Pro shape data-ready but do not implement Spec 7 paywall UI or purchase flows.
- This step is 2-3 hours and build-green.

## Phase 3: Riverpod Application Seams

### Step 3.1: Add Study Plan providers

**Goal:** Wire plan preferences, selected exam, content volume, review counts, assessment mastery, and mock history into a single `studyPlanViewProvider`.

**Files to create/edit:**
- Create: `lib/features/study_plan/application/study_plan_providers.dart`
- Test: `test/features/study_plan/application/study_plan_providers_test.dart`

**Tests to write first:**
- `studyPlanViewProvider computes a plan for the active exam`
- `studyPlanViewProvider emits selection-needed state without an active exam`
- `changing intensity invalidates and recomputes the plan`
- `changing exam date invalidates and recomputes the plan`
- `provider overrides can inject fake mastery and content volume`

**Non-obvious implementation notes:**
- Use existing `activeExamFocusProvider`, `topicsByExamProvider`, `reviewStateRepositoryProvider`, `assessmentRepositoryProvider`, and mock attempt repository seams where present.
- If a dependency is absent, inject a small adapter provider with a conservative default rather than reaching across layers.
- This step is 2-3 hours and build-green.

### Step 3.2: Add plan preference cloud seam without live dependency

**Goal:** Prepare Firestore native partial-field updates behind a tested interface while keeping live validation skippable.

**Files to create/edit:**
- Create: `lib/features/study_plan/data/plan_prefs_gateway.dart`
- Create: `test/features/study_plan/data/plan_prefs_gateway_test.dart`
- Modify: `test/tool/study_plan_boundary_test.dart`

**Tests to write first:**
- `exam date update serializes only examDate and examDateIsProvisional`
- `intensity update serializes only intensityPreset`
- `acknowledgement update serializes only acknowledgement timestamp`
- `gateway file is the only study plan file allowed to import cloud_firestore`

**Non-obvious implementation notes:**
- Do not require live Firebase credentials; test serialization through a pure command object or fake gateway.
- Do not route these writes through `SyncCoordinator`; Spec 6 explicitly uses native partial-field semantics.
- This step is 1-2 hours and build-green.

## Phase 4: Plan Route And Widgets

### Step 4.1: Build reusable plan widgets

**Goal:** Render the default plan density with one primary CTA and read-only upcoming/mock/collapsed sections.

**Files to create/edit:**
- Create: `lib/features/study_plan/presentation/today_inset.dart`
- Create: `lib/features/study_plan/presentation/upcoming_day_chip.dart`
- Create: `lib/features/study_plan/presentation/mock_week_card.dart`
- Create: `lib/features/study_plan/presentation/collapsed_plan_section.dart`
- Create: `lib/features/study_plan/presentation/plan_updated_chip.dart`
- Test: `test/features/study_plan/presentation/today_inset_test.dart`
- Test: `test/features/study_plan/presentation/plan_widgets_test.dart`

**Tests to write first:**
- `today inset renders exactly one primary CTA`
- `today inset shows review lesson and drill counts as read-only breakdown`
- `upcoming day chips do not expose buttons`
- `mock week card is preview only before mock week`
- `plan updated chip can be dismissed`
- `rest day renders endorsed rest copy`

**Non-obvious implementation notes:**
- Reuse existing `AppCard` and `AppButton` primitives.
- Keep text compact so widget tests can run with narrow phone constraints.
- This step is 2-3 hours and build-green.

### Step 4.2: Add `/plan` full-screen route

**Goal:** Add the non-shell `/plan` page that renders the plan view, loading/error/empty states, and the start-today CTA.

**Files to create/edit:**
- Create: `lib/features/study_plan/presentation/plan_page.dart`
- Modify: `lib/app/router.dart`
- Test: `test/features/study_plan/presentation/plan_page_test.dart`
- Test: `test/app/router_redirect_test.dart`

**Tests to write first:**
- `/plan route builds outside the shell`
- `loading state renders progress indicator`
- `missing plan prefs renders exam-date prompt`
- `plan page CTA navigates to today's quiz route`
- `plan updated chip appears after pending rebalance`

**Non-obvious implementation notes:**
- Keep `/plan` independent of bottom navigation; it should be a full-screen route.
- CTA should navigate to `/quiz/today/:examId` with an optional `topicId` query if the plan preview has a topic recommendation.
- This step is 2-3 hours and build-green.

### Step 4.3: Add Home/Quiz entry surfaces

**Goal:** Surface the Study Plan daily recommendation from existing app entry points without redesigning Home or implementing Spec 7 monetization.

**Files to create/edit:**
- Create: `lib/features/study_plan/presentation/home_plan_card.dart`
- Modify: `lib/features/quiz/presentation/quiz_tab_home.dart`
- Test: `test/features/study_plan/presentation/home_plan_card_test.dart`
- Test: `test/features/quiz/presentation/quiz_tab_home_test.dart`

**Tests to write first:**
- `home plan card shows weeks to exam and pace status`
- `home plan card opens /plan`
- `quiz tab today's session button follows plan topic recommendation when available`
- `quiz tab falls back to existing today's session route when plan is unavailable`

**Non-obvious implementation notes:**
- Do not add a new bottom-nav tab unless an existing shell redesign lands; the design doc locked `/plan` as a full-screen route reached from a card.
- Keep Spec 7 out: no upgrade button, purchase flow, entitlement gate, or paywall teaser in this step.
- This step is 2-3 hours and build-green.

## Phase 5: Docs, Guardrails, And Final Verification

### Step 5.1: Document parked live work and manual QA

**Goal:** Record what remains blocked outside local implementation and how to validate it later.

**Files to create/edit:**
- Create: `docs/superpowers/plans/2026-05-21-study-plan-live-validation.md`
- Modify: `docs/superpowers/plans/2026-05-21-study-plan-plan.md` only for completed checkbox tracking or genuine corrections.

**Tests to write first:**
- `documentation names content db as regenerable and excludes it from sync` in `test/tool/content_docs_test.dart` or a new `test/tool/study_plan_docs_test.dart`

**Non-obvious implementation notes:**
- Include exact manual actions for Sanity `targetMastery`, seed regeneration, Firebase live partial-write validation, emulator/CI credentials, Android QA, and production release verification.
- This step is 1 hour and build-green.

### Step 5.2: Run focused and full verification

**Goal:** Prove the full implementation is green before final reporting.

**Files to create/edit:**
- Modify only files required to fix verification failures caused by Spec 6 changes.

**Tests to write first:**
- No new tests unless final verification exposes a real missing guardrail or regression.

**Non-obvious implementation notes:**
- Run focused Study Plan tests first, then `flutter test`, `flutter analyze`, and existing guardrails including layering and attribution checks.
- Do not run live Firebase/Sanity work while credentials and project access are blocked.
- This step is 1-3 hours and build-green.
