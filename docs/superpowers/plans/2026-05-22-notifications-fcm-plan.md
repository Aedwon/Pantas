# Notifications Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build Spec 9's Android-v1 local notification flow: daily reminders, streak-save warnings, permission recovery, lifecycle rescheduling, notification-tap routing, and cancel seams without FCM token storage or server push.

**Architecture:** `lib/features/notifications/` owns pure scheduling/copy policy, a fakeable gateway, Riverpod service providers, permission UI, lifecycle hooks, and tap parsing. Existing features call only `notificationServiceProvider`: Settings saves reminder time through it, Quiz completion cancels streak-save, Auth/local wipe cancels all pending notifications, and router/bootstrap can interpret launch payloads.

**Tech Stack:** Flutter, Riverpod, GoRouter, Drift-backed Settings/account prefs, `flutter_local_notifications`, `timezone`, `app_settings`, focused Flutter tests with fake gateways, existing static guardrails.

**Target spec:** `docs/superpowers/specs/2026-05-22-notifications-fcm-design.md`

**Roadmap anchor:** `docs/superpowers/specs/2026-05-16-mvp-roadmap-design.md` Spec 9 - Notifications (FCM)

**Date:** 2026-05-22

**Size:** M

---

## Open Questions

- Should the notification rationale route be inserted at the end of current onboarding now, or should onboarding keep routing Home until the diagnostic/exam-date completion screen exists? Tentative decision: implement `/notifications/rationale` and its once-per-install flag now; add a router seam that can be enabled from onboarding without changing notification internals.
- Current Study Plan's generated Today headline is "Focus on {topic} today", not the exact copy table in Spec 9. Tentative decision: daily notification composer consumes `TodayPlan` and maps the available fields to Spec 9's copy table with a safe fallback.
- Current `/quiz/today` route requires an exam id (`/quiz/today/:examId`). Tentative decision: tap handler resolves `PlanView.today.ctaPath` when plan is ready, and falls back to `/home` when stale or plan-not-ready.

## External Blockers

- **Skippable: dependency fetch.** Run `flutter pub get` after adding `flutter_local_notifications`, `timezone`, and `app_settings`; if network is blocked, commit Dart code and report dependency resolution as blocked.
- **Skippable: Android 13+ permission prompt validation.** Manual action: run a dev build on Android 13+ and verify the system `POST_NOTIFICATIONS` prompt appears only from the rationale CTA.
- **Skippable: real notification delivery.** Manual action: on target Android hardware, grant notifications, schedule a daily reminder and streak-save, lock the screen, and verify fire time, sound/vibration, and channel names.
- **Skippable: OS notification settings deep link.** Manual action: deny notifications and verify the Settings reminder row/snackbar action opens app notification settings through `app_settings`.
- **Skippable: cold-tap launch payload.** Manual action: tap a delivered notification from a killed app and confirm stale taps land Home while current taps land Today's Session.
- **Skippable: iOS/APNs validation.** Deferred to v1.x after Apple enrollment; do not add APNs keys, entitlements, or iOS QA claims in this implementation.

## File Structure

- Create `lib/features/notifications/notifications.dart` as the public feature barrel.
- Create `lib/features/notifications/domain/` for `notification_permission.dart`, `notification_body_composer.dart`, `streak_save_policy.dart`, `reminder_schedule.dart`, and `notification_payload.dart`.
- Create `lib/features/notifications/data/notifications_gateway.dart` and `flutter_local_notifications_gateway.dart`; only the concrete gateway imports plugin packages.
- Create `lib/features/notifications/application/notification_service.dart` and `notifications_providers.dart` for scheduling, permission requests, app-settings recovery, and fakeable provider seams.
- Create `lib/features/notifications/presentation/permission_rationale_page.dart`, `notification_tap_handler.dart`, and `notifications_lifecycle_observer.dart`.
- Modify `pubspec.yaml` for local notification dependencies.
- Modify `lib/app/bootstrap.dart` and `lib/app/router.dart` for gateway initialization, lifecycle observation, rationale/tap routes, and current-tap fallback.
- Modify `lib/features/settings/application/settings_providers.dart` and `lib/features/settings/presentation/settings_home_page.dart` to replace the Spec 9 placeholder scheduler with the notification seam and permission recovery copy/action.
- Modify `lib/features/quiz/domain/use_cases/complete_quiz.dart` and `lib/features/quiz/presentation/quiz_controller.dart` so session completion calls `onSessionCompleted()`.
- Modify `lib/core/sync/local_state_wiper.dart` or provider wiring to call `cancelAll()` during local wipe without creating a cyclic import.
- Add tests under `test/features/notifications/`, targeted updates under `test/features/settings/`, `test/features/quiz/`, `test/core/sync/`, `test/app/`, and static guardrails under `test/tool/`.

## Phase 1: Boundaries, Packages, And Pure Domain

### Task 1.1: Add notification boundary guardrails and dependencies

**Goal:** Lock down package/layering boundaries and add the local notification packages without any production scheduling behavior.

**Files to create/edit:**
- Create: `test/tool/notifications_boundary_test.dart`
- Modify: `test/tool/sync_import_boundary_test.dart`
- Modify: `test/tool/settings_boundary_test.dart`
- Modify: `pubspec.yaml`

**Tests to write first:**
- `notifications domain files do not import Flutter plugins Firebase Drift GoRouter or Riverpod`
- `only flutter local notifications gateway imports flutter_local_notifications timezone and app_settings`
- `notifications files do not import firebase_messaging`
- `sync module does not import notifications presentation`
- `pubspec includes local notifications timezone and app settings but no new FCM sender dependency`

**Non-obvious implementation notes:**
- Keep `firebase_messaging` as an existing dormant dependency; do not add token calls or background handlers.
- Add `flutter_local_notifications`, `timezone`, and `app_settings` only; no server push Functions or Firestore token collections.
- This step is 1 hour and build-green.

### Task 1.2: Implement notification copy and payload domain

**Goal:** Produce deterministic daily reminder, streak-save, freeze, fallback, and tap payload strings from pure inputs.

**Files to create/edit:**
- Create: `lib/features/notifications/domain/notification_body_composer.dart`
- Create: `lib/features/notifications/domain/notification_payload.dart`
- Create: `lib/features/notifications/domain/notification_permission.dart`
- Create: `lib/features/notifications/notifications.dart`
- Test: `test/features/notifications/domain/notification_body_composer_test.dart`
- Test: `test/features/notifications/domain/notification_payload_test.dart`

**Tests to write first:**
- `standard daily reminder includes review count`
- `mock daily reminder uses mock day copy`
- `behind daily reminder uses welcome back copy`
- `calm daily reminder uses quick check in copy`
- `first post diagnostic daily reminder uses plan set copy`
- `daily reminder falls back when plan is unavailable`
- `streak save copy covers 1 2 6 7 29 30 and 100 day tiers`
- `streak save freeze copy surfaces remaining freezes`
- `payload encodes kind and scheduled_for iso timestamp`
- `payload rejects unknown kind and malformed scheduled_for`

**Non-obvious implementation notes:**
- Avoid Unicode punctuation in Dart strings unless the file already uses it; use straight apostrophes and hyphens.
- Do not mention FCM, vendors, tools, analytics, or attribution in user-visible copy.
- This step is 1-2 hours and build-green.

### Task 1.3: Implement streak-save policy and schedule model

**Goal:** Compute daily/streak fire times, past-window skipping, and schedule records without calling platform plugins.

**Files to create/edit:**
- Create: `lib/features/notifications/domain/streak_save_policy.dart`
- Create: `lib/features/notifications/domain/reminder_schedule.dart`
- Test: `test/features/notifications/domain/streak_save_policy_test.dart`
- Test: `test/features/notifications/domain/reminder_schedule_test.dart`

**Tests to write first:**
- `reminder 19:00 produces streak save 18:00`
- `reminder 20:30 produces streak save 19:30`
- `reminder 21:00 caps streak save at 20:00`
- `reminder 22:00 caps streak save at 20:00`
- `reminder 06:00 produces early edge case 05:00`
- `does not schedule streak save when streak length is zero`
- `does not schedule streak save when today already completed`
- `does not schedule streak save in the past`
- `daily reminder schedules next occurrence today when future and tomorrow when past`

**Non-obvious implementation notes:**
- Use the existing `SettingsTime` type for reminder times.
- Store notification ids as constants: daily `9001`, streak-save `9002`.
- This step is 1-2 hours and build-green.

## Phase 2: Gateway, Service, And Providers

### Task 2.1: Add fakeable notifications gateway

**Goal:** Define the plugin-independent scheduling/permission contract and add a concrete plugin adapter behind it.

**Files to create/edit:**
- Create: `lib/features/notifications/data/notifications_gateway.dart`
- Create: `lib/features/notifications/data/flutter_local_notifications_gateway.dart`
- Test: `test/features/notifications/data/notifications_gateway_contract_test.dart`
- Test: `test/tool/notifications_boundary_test.dart`

**Tests to write first:**
- `fake gateway records initialize schedule cancel and cancelAll calls`
- `fake gateway emits permission status changes`
- `fake gateway records app notification settings requests`
- `production gateway is the only file that imports plugin packages`

**Non-obvious implementation notes:**
- `FlutterLocalNotificationsGateway.initialize()` should create `daily_reminder` and `streak_save` Android channels.
- Use one-shot zoned scheduling with exact-allow-while-idle where plugin support is available.
- Keep real plugin behavior out of CI tests; fake gateway verifies contracts.
- This step is 2-3 hours and build-green.

### Task 2.2: Add NotificationService and provider surface

**Goal:** Expose Spec 9's public service methods and schedule 0-2 notifications through the fakeable gateway.

**Files to create/edit:**
- Create: `lib/features/notifications/application/notification_service.dart`
- Create: `lib/features/notifications/application/notifications_providers.dart`
- Test: `test/features/notifications/application/notification_service_test.dart`
- Test: `test/features/notifications/application/notifications_providers_test.dart`

**Tests to write first:**
- `scheduleDailyReminder cancels existing notification ids then schedules daily reminder`
- `scheduleDailyReminder also schedules eligible streak save`
- `scheduleDailyReminder skips all scheduling when permission is denied`
- `onSessionCompleted cancels only today streak save`
- `rescheduleForForeground reads settings and plan then rewrites schedule`
- `requestPermission delegates to gateway and emits refreshed status`
- `cancelAll delegates to gateway`

**Non-obvious implementation notes:**
- Inject `now`, `settingsReader`, `planReader`, and `streakReader` into the service so tests do not depend on live providers.
- Map `StudyPlanReady.view.today.ctaPath` into daily tap payload metadata; if plan state is not ready, use fallback copy and Home fallback on tap.
- This step is 2-3 hours and build-green.

### Task 2.3: Wire Settings reminder save and permission recovery

**Goal:** Replace the Spec 8 placeholder result with real reminder scheduling and OS-settings recovery seams.

**Files to create/edit:**
- Modify: `lib/features/settings/application/settings_providers.dart`
- Modify: `lib/features/settings/presentation/settings_home_page.dart`
- Test: `test/features/settings/application/settings_actions_test.dart`
- Test: `test/features/settings/presentation/settings_home_page_test.dart`

**Tests to write first:**
- `saving reminder time writes settings and calls notification scheduler`
- `saving reminder time returns notifications disabled when permission is denied`
- `daily reminder row shows notifications off recovery subtitle when permission denied`
- `daily reminder row requests app notification settings when permission denied`

**Non-obvious implementation notes:**
- Keep the Setting row's normal subtitle as `HH:mm`; only replace it with recovery copy when permission is denied.
- Do not attempt to re-request permission from Settings; route to OS settings only.
- This step is 1-2 hours and build-green.

## Phase 3: Routing, Permission Rationale, And Taps

### Task 3.1: Add permission rationale page and once-per-install flag

**Goal:** Add the onboarding-ready rationale page that requests permission only from the primary CTA and records a device-local shown flag.

**Files to create/edit:**
- Create: `lib/features/notifications/presentation/permission_rationale_page.dart`
- Modify: `lib/features/notifications/application/notifications_providers.dart`
- Modify: `lib/app/router.dart`
- Test: `test/features/notifications/presentation/permission_rationale_page_test.dart`
- Test: `test/app/router_redirect_test.dart`

**Tests to write first:**
- `sounds good requests permission marks rationale shown and routes home`
- `not right now marks rationale shown without requesting permission and routes home`
- `rationale flag defaults false`
- `/notifications/rationale` renders without shell chrome`

**Non-obvious implementation notes:**
- Persist the flag in `device_prefs` to avoid adding `shared_preferences`.
- Do not force onboarding redirects yet if the current onboarding flow lacks a final diagnostic/plan-set seam; expose the route and flag cleanly.
- This step is 1-2 hours and build-green.

### Task 3.2: Add notification tap handler and route fallback

**Goal:** Convert warm/cold notification payloads into `/quiz/today/:examId?...` or `/home` without stale or plan-not-ready surprises.

**Files to create/edit:**
- Create: `lib/features/notifications/presentation/notification_tap_handler.dart`
- Modify: `lib/app/router.dart`
- Test: `test/features/notifications/presentation/notification_tap_handler_test.dart`
- Test: `test/app/router_redirect_test.dart`

**Tests to write first:**
- `fresh payload with ready plan routes to today cta path`
- `payload older than four hours routes home`
- `malformed payload routes home`
- `plan-not-ready routes home`
- `onboarding redirect still wins over notification target`

**Non-obvious implementation notes:**
- Current Today's Session route is `/quiz/today/:examId`, so never hardcode `/quiz/today` as a final GoRouter location.
- Keep payload parsing telemetry-ready but do not fire analytics events.
- This step is 1-2 hours and build-green.

### Task 3.3: Add lifecycle observer for foreground and day-boundary reschedule

**Goal:** Reschedule on app resume and while-foreground day-boundary crossings without background tasks.

**Files to create/edit:**
- Create: `lib/features/notifications/presentation/notifications_lifecycle_observer.dart`
- Modify: `lib/app/bootstrap.dart`
- Test: `test/features/notifications/presentation/notifications_lifecycle_observer_test.dart`
- Test: `test/app/app_boot_test.dart`

**Tests to write first:**
- `resumed calls rescheduleForForeground`
- `paused cancels day-boundary timer`
- `foreground day boundary calls reschedule once`
- `bootstrap registers lifecycle observer after runApp container exists`

**Non-obvious implementation notes:**
- Inject timer factory and clock for tests; production uses a five-minute periodic timer.
- Do not add WorkManager or background execution.
- This step is 1-2 hours and build-green.

## Phase 4: Cross-Spec Cancel And Completion Seams

### Task 4.1: Cancel notifications on quiz completion

**Goal:** Ensure session completion cancels pending streak-save for the day through the notification service seam.

**Files to create/edit:**
- Modify: `lib/features/quiz/domain/use_cases/complete_quiz.dart`
- Modify: `lib/features/quiz/presentation/quiz_controller.dart`
- Test: `test/features/quiz/domain/use_cases/complete_quiz_test.dart`
- Test: `test/features/quiz/presentation/quiz_controller_test.dart`

**Tests to write first:**
- `complete quiz calls notification session completed after streak evaluation`
- `complete quiz still saves attempt when notification cancel fails is surfaced as failure`
- `quiz controller injects notification seam into complete use case`

**Non-obvious implementation notes:**
- Use a small `SessionCompletionNotifier` interface to avoid importing notification application code into quiz domain.
- If cancellation fails, do not fake success; let the focused test define whether the exception bubbles or is caught. Prefer bubbling in domain tests and handling in controller if UX requires.
- This step is 1-2 hours and build-green.

### Task 4.2: Cancel notifications on sign-out, local wipe, and delete seam

**Goal:** Cancel all pending notifications before destructive local/account flows continue.

**Files to create/edit:**
- Modify: `lib/core/sync/local_state_wiper.dart`
- Modify: `lib/core/sync/providers.dart`
- Modify: `lib/features/settings/presentation/pages/delete_account_page.dart`
- Test: `test/core/sync/local_state_wiper_test.dart`
- Test: `test/features/settings/presentation/delete_account_page_test.dart`

**Tests to write first:**
- `local state wiper cancels notifications before deleting user data`
- `local state wiper preserves device id after notification cancel`
- `delete account page calls cancelAll before named delete action`
- `delete account page calls cancelAll before anonymous local wipe action`

**Non-obvious implementation notes:**
- Avoid a sync -> notifications import cycle by injecting a `LocalWipeNotificationsGateway` interface or callback into `SyncLocalStateWiper`.
- Do not implement new Spec 10 backend behavior; only call the existing delete/local-wipe seams if present.
- This step is 1-2 hours and build-green.

## Phase 5: Final Guardrails And Documentation

### Task 5.1: Add FCM/server-push and attribution guardrails

**Goal:** Prove Spec 9 did not accidentally add FCM token storage, server push Functions, content sync, or attribution strings.

**Files to create/edit:**
- Create: `test/tool/notifications_no_fcm_token_test.dart`
- Modify: `test/tool/content_docs_test.dart` only if docs index needs the new plan/spec path.
- Test: `test/tool/notifications_no_fcm_token_test.dart`

**Tests to write first:**
- `app code never calls FirebaseMessaging getToken subscribeToTopic or onBackgroundMessage`
- `Firestore rules and Functions do not add device token collections`
- `Functions do not add notification sender functions`
- `notifications implementation does not sync content database`
- `notifications implementation contains no tool model or vendor attribution strings`

**Non-obvious implementation notes:**
- Text-scan only; do not import Firebase Messaging in tests.
- Existing dormant `firebase_messaging` dependency is allowed by the test.
- This step is 1 hour and build-green.

### Task 5.2: Run focused suite, full verification, and document parked work

**Goal:** Verify the feature and leave clear notes for external/device work and deferred specs.

**Files to create/edit:**
- Create: `docs/superpowers/plans/2026-05-22-notifications-live-validation.md`
- Test: focused notification/settings/quiz/router/tool tests

**Tests to write first:**
- `notifications live validation doc lists Android permission delivery tap and OS settings checks`
- `notifications live validation doc parks FCM server push APNs telemetry and quiet hours`

**Non-obvious implementation notes:**
- Run focused tests after each task, then final `flutter test`, `flutter analyze`, and any Functions tests only if `functions/` was touched.
- Do not claim real OS delivery, APNs, FCM server push, analytics, or account deletion production validation passed unless manually performed.
- This step is 1 hour and build-green.
