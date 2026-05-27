# Settings + Account Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build Spec 8's Settings tab, account surfaces, synced/local settings repository, backup diagnostics, subscription route, About/legal seams, and guardrails without syncing `content.db` or implementing Specs 9-11.

**Architecture:** Settings is a thin feature shell over existing seams: auth from `lib/core/auth`, sync status from `lib/core/sync`, plan-date persistence from `lib/features/study_plan`, entitlement/subscription content from `lib/features/paywall`, strict mock mode from `lib/features/mock_exam`, and legal/delete seams from existing routes/functions. Synced user preferences use the existing `account_prefs` table and `PreferencesMapper`; device-local theme uses existing `device_prefs`, keeping `app.db` as user data and `content.db` as regenerable content only.

**Tech Stack:** Flutter, Riverpod, GoRouter, Drift, Firebase Analytics seam, existing Cloud Functions static tests, Flutter widget tests, pure Dart domain tests, tool guardrails.

**Target spec:** `docs/superpowers/specs/2026-05-22-settings-account-design.md`

**Roadmap anchor:** `docs/superpowers/specs/2026-05-16-mvp-roadmap-design.md` Spec 8 - Settings + account

**Date:** 2026-05-22

**Size:** M

---

## Open Questions

- Should theme persistence add `shared_preferences`, or should v1 keep using existing `device_prefs` to avoid a new persistence dependency? Tentative decision: use `device_prefs`; it is device-local and already survives sign-out.
- Should Account deletion for anonymous users call the named-user Cloud Function? Tentative decision: do not fake backend success; anonymous delete uses the local wipe seam and named delete uses `AuthRepository.deleteAccount()`.
- What are the production support and DPO email addresses? Tentative decision: centralize placeholders in Settings constants and keep all mailto seams testable.
- Should notification permission status be visible before Spec 9 lands? Tentative decision: ship a disabled seam/provider that reports unsupported, and do not schedule or deep-link beyond row copy.

## External Blockers

- **Skippable: live Firebase account deletion validation.** Manual action: run delete flow against Firebase emulators or dev project with App Check debug token and verify callable behavior, auth sign-out, and local wipe.
- **Skippable: real notification scheduling and OS settings link.** Manual action: Spec 9 must provide local notification scheduling, permission status, and app-settings deep link service.
- **Skippable: legal content source.** Manual action: Spec 10 must replace `/legal/privacy` and `/legal/terms` stubs with Sanity-sourced in-app legal pages and final DPO/support addresses.
- **Skippable: production subscription management link.** Manual action: validate Google Play manage-subscription link on an Internal Testing build with license testers.
- **Skippable: manual Android QA.** Manual action: verify Settings tab layout, sign-in/sign-out/delete confirmations, Backup states, mailto intents, and date/time pickers on target Android hardware.

## File Structure

- Create `lib/features/settings/settings.dart` as the feature barrel.
- Create `lib/features/settings/domain/` for user settings entities, theme enum conversion, account state, backup status mapping, delete-account copy, and feedback/legal link builders.
- Create `lib/features/settings/data/settings_repository.dart` for `account_prefs` and `device_prefs` persistence plus injectable analytics consent seam.
- Create `lib/features/settings/application/settings_providers.dart` for Riverpod aggregates over auth, sync, entitlement, settings repository, study-plan date update, strict mock mode, and external action seams.
- Create `lib/features/settings/presentation/` pages and widgets for Settings home, Account, Delete Account, Subscription, Backup, About, Debug, rows, switches, and theme segmented control.
- Modify `lib/app/app.dart` to wire `themeModeProvider` into `MaterialApp.router.themeMode`.
- Modify `lib/app/router.dart` to make `/more` render Settings and add `/settings/account`, `/settings/account/delete`, `/settings/subscription`, `/settings/backup`, `/settings/about`, and guarded `/settings/_debug`.
- Modify sync guardrails to ensure preferences remain in `app.db` and `content.db` is never imported by Settings or sync.
- Add tests under `test/features/settings/`, router tests under `test/app/`, and tool guardrails under `test/tool/`.

## Phase 1: Settings Boundaries And Preference Repository

### Task 1.1: Add settings guardrails

**Goal:** Lock down Settings boundaries before adding production code.

**Files to create/edit:**
- Create: `test/tool/settings_boundary_test.dart`
- Modify: `test/tool/sync_import_boundary_test.dart`

**Tests to write first:**
- `settings domain files do not import Flutter Firebase Drift GoRouter or feature presentation`
- `settings feature does not import content database or content sync modules`
- `content database does not contain user settings tables`
- `sync registry syncs preferences but does not sync content database`
- `settings files do not contain tool model or vendor attribution strings`

**Non-obvious implementation notes:**
- Follow the text-scanning style in `test/tool/study_plan_boundary_test.dart` and `test/tool/paywall_release_guard_test.dart`.
- The existing `PreferencesMapper` already syncs `account_prefs`; this task should assert that direction instead of introducing a new table.
- This step is 1 hour and build-green.

### Task 1.2: Implement user and device settings repository

**Goal:** Persist Spec 8 preferences with synced `account_prefs` for user settings and local `device_prefs` for theme.

**Files to create/edit:**
- Create: `lib/features/settings/domain/user_settings.dart`
- Create: `lib/features/settings/domain/theme_preference.dart`
- Create: `lib/features/settings/data/settings_repository.dart`
- Create: `lib/features/settings/settings.dart`
- Test: `test/features/settings/data/settings_repository_test.dart`
- Test: `test/features/settings/domain/settings_domain_test.dart`

**Tests to write first:**
- `returns default user settings when account prefs are missing`
- `updates reminder time and bumps updatedAt`
- `updates exam date only for tomorrow or later and bumps updatedAt`
- `updates strict mock mode in account prefs`
- `updates help improve app and calls analytics consent gate`
- `theme mode defaults to system from device prefs`
- `theme mode writes only device prefs and never account prefs`

**Non-obvious implementation notes:**
- Store reminder time as `HH:mm`, exam date as `yyyy-MM-dd`, booleans as `true`/`false`, and `updatedAt` as ISO-8601 UTC in `account_prefs`.
- Keep `updatedAt` under a settings key such as `settings.updated_at`; `PreferencesMapper` will include it in the synced preferences document.
- Use an injectable `AnalyticsConsentGateway` interface so tests do not touch Firebase.
- Accept tomorrow as the earliest exam date; this tightens Spec 6's earlier "not before today" behavior for Settings only.
- This step is 2-3 hours and build-green.

### Task 1.3: Add Settings providers and theme app wiring

**Goal:** Expose settings state through Riverpod and apply device-local theme mode at app root.

**Files to create/edit:**
- Create: `lib/features/settings/application/settings_providers.dart`
- Modify: `lib/app/app.dart`
- Test: `test/features/settings/application/settings_providers_test.dart`
- Test: `test/app/app_boot_test.dart`

**Tests to write first:**
- `userSettingsProvider reads repository defaults`
- `themeModeProvider initializes from repository`
- `themeModeController writes selected theme`
- `MaterialApp uses selected themeMode`
- `analytics consent gateway is invoked when help improve app changes`

**Non-obvious implementation notes:**
- Keep provider overrides simple; default repository can throw until app bootstrap wires a real database if an existing database provider is not available.
- Do not add analytics event taxonomy or custom event firing.
- This step is 1-2 hours and build-green.

## Phase 2: Settings Home And Preferences UI

### Task 2.1: Build reusable Settings controls

**Goal:** Create stable row, section, theme segmented control, and iOS-style switch widgets for Settings screens.

**Files to create/edit:**
- Create: `lib/features/settings/presentation/widgets/settings_section.dart`
- Create: `lib/features/settings/presentation/widgets/settings_row.dart`
- Create: `lib/features/settings/presentation/widgets/ios_switch.dart`
- Create: `lib/features/settings/presentation/widgets/theme_segmented_control.dart`
- Test: `test/features/settings/presentation/settings_widgets_test.dart`

**Tests to write first:**
- `settings row renders title subtitle and chevron`
- `settings row invokes tap callback`
- `ios switch renders on and off labels accessibly`
- `theme segmented control shows light dark system and calls selection`
- `section renders uppercase header and children`

**Non-obvious implementation notes:**
- Use Material widgets and compact dimensions; avoid adding icon packages.
- The switch should be oval, green when on, gray when off, with stable dimensions.
- This step is 1-2 hours and build-green.

### Task 2.2: Build Settings home page

**Goal:** Render the Preferences, Account, and About groups with inline controls and navigation rows.

**Files to create/edit:**
- Create: `lib/features/settings/presentation/settings_home_page.dart`
- Modify: `lib/app/router.dart`
- Test: `test/features/settings/presentation/settings_home_page_test.dart`
- Test: `test/app/router_redirect_test.dart`

**Tests to write first:**
- `home renders Preferences Account About in order`
- `anonymous user shows signed in anonymously account subtitle`
- `named user shows email account subtitle`
- `subscription row reflects free and pro entitlement states`
- `backup row reflects anonymous saved syncing and failed summaries`
- `theme chips update theme provider`
- `strict mock and help improve app switches call provider actions`
- `/more renders settings home as fourth bottom nav tab`

**Non-obvious implementation notes:**
- The reminder row can show "Not set" and a Spec 9 unavailable warning until notification service lands.
- The exam-date row calls the settings date update action, then reuses Study Plan's pending-chip behavior through `DriftPlanPrefsRepository.setExamDate(..., provisional: false)`.
- Send feedback builds a mailto URI but tests should assert the seam receives it instead of launching a platform intent.
- This step is 2-3 hours and build-green.

### Task 2.3: Add picker action seams

**Goal:** Wire exam-date and reminder-time save actions without implementing Spec 9 notification delivery.

**Files to create/edit:**
- Modify: `lib/features/settings/application/settings_providers.dart`
- Modify: `lib/features/settings/presentation/settings_home_page.dart`
- Test: `test/features/settings/application/settings_actions_test.dart`
- Test: `test/features/settings/presentation/settings_picker_actions_test.dart`

**Tests to write first:**
- `saving exam date writes settings and study plan prefs then returns rebalance snackbar text`
- `saving past or today exam date rejects without writing`
- `saving reminder time writes settings and reports notification scheduling unavailable`
- `dismissed date picker preserves existing value`
- `dismissed time picker preserves existing value`

**Non-obvious implementation notes:**
- Do not schedule local notifications; expose a `ReminderScheduler` seam returning an unavailable result until Spec 9.
- Show snackbars from page callbacks only after successful writes.
- This step is 1-2 hours and build-green.

## Phase 3: Account, Delete Account, And Subscription Detail

### Task 3.1: Add account state and Account page

**Goal:** Render anonymous and named Account detail variants with sign-in, sign-out, and delete-entry actions.

**Files to create/edit:**
- Create: `lib/features/settings/domain/account_state.dart`
- Create: `lib/features/settings/presentation/pages/account_page.dart`
- Modify: `lib/features/settings/application/settings_providers.dart`
- Modify: `lib/app/router.dart`
- Test: `test/features/settings/domain/account_state_test.dart`
- Test: `test/features/settings/presentation/account_page_test.dart`

**Tests to write first:**
- `accountState maps anonymous auth to anonymous settings state`
- `accountState maps signed in auth to named settings state`
- `anonymous page shows sign in CTA and delete my data row`
- `named page shows display name email sign out and delete account`
- `sign out dialog includes pending queue warning when pending count is positive`
- `confirm sign out calls AuthRepository.signOut`

**Non-obvious implementation notes:**
- Spec 1 D7 resolved sign-out semantics: local Drift data is wiped and a fresh anonymous session starts. Use the wipe-copy variant.
- Do not implement profile editing.
- This step is 2-3 hours and build-green.

### Task 3.2: Add delete-account confirmation screen

**Goal:** Provide the dedicated destructive confirmation surface with subscription-aware copy and real auth/delete seams.

**Files to create/edit:**
- Create: `lib/features/settings/domain/delete_account_copy.dart`
- Create: `lib/features/settings/presentation/pages/delete_account_page.dart`
- Modify: `lib/app/router.dart`
- Test: `test/features/settings/domain/delete_account_copy_test.dart`
- Test: `test/features/settings/presentation/delete_account_page_test.dart`

**Tests to write first:**
- `free named copy omits billing line`
- `active monthly or yearly copy warns billing continues until Play cancellation`
- `trial copy warns trial ends and future billing needs Play cancellation`
- `lifetime copy warns Pro Lifetime access can be lost`
- `cancelled subscription copy uses end date`
- `anonymous lifetime copy warns sign in first`
- `final named delete calls AuthRepository.deleteAccount and shows loading`
- `delete failure shows retry and DPO fallback`

**Non-obvious implementation notes:**
- Do not claim backend deletion succeeds unless the callable returns; surface error state and mailto fallback on failure.
- Anonymous delete should call the local wipe seam and return to onboarding; named delete uses `AuthRepository.deleteAccount()`.
- This step is 2-3 hours and build-green.

### Task 3.3: Add subscription detail wrapper

**Goal:** Route `/settings/subscription` to Spec 7's subscription panel without duplicating subscription copy.

**Files to create/edit:**
- Create: `lib/features/settings/presentation/pages/subscription_page.dart`
- Modify: `lib/app/router.dart`
- Test: `test/features/settings/presentation/subscription_page_test.dart`

**Tests to write first:**
- `subscription page renders app bar and SubscriptionPanel`
- `free state exposes Try Pro and Restore Purchases`
- `pro state exposes Manage in Google Play when renewable`
- `back navigation pops to settings`

**Non-obvious implementation notes:**
- Keep body delegated to `SubscriptionPanel`.
- Manage/restore can be seam callbacks; live Play validation remains external.
- This step is 1 hour and build-green.

## Phase 4: Backup, About, Debug, And Legal Seams

### Task 4.1: Add backup diagnostics page

**Goal:** Map existing `SyncStatus` and auth state to the five Spec 8 Backup states with collapsible diagnostics.

**Files to create/edit:**
- Create: `lib/features/settings/domain/backup_status.dart`
- Create: `lib/features/settings/presentation/pages/backup_page.dart`
- Test: `test/features/settings/domain/backup_status_test.dart`
- Test: `test/features/settings/presentation/backup_page_test.dart`

**Tests to write first:**
- `anonymous backup status asks user to sign in`
- `idle or ok status renders progress saved`
- `syncing status renders pending count`
- `failed status renders retry action`
- `show details reveals last sync iso pending queue and network placeholder`
- `sync now calls manualSyncRetryProvider`

**Non-obvious implementation notes:**
- Existing `SyncStatus` has no offline status yet; map unsupported offline diagnostics to a placeholder and do not invent network monitoring.
- Manual sync uses `manualSyncRetryProvider`.
- This step is 1-2 hours and build-green.

### Task 4.2: Add About page and legal/contact seams

**Goal:** Render app version/build, Privacy Policy, ToS, and DPO contact rows without implementing Spec 10 legal backend content.

**Files to create/edit:**
- Create: `lib/features/settings/domain/settings_links.dart`
- Create: `lib/features/settings/presentation/pages/about_page.dart`
- Modify: `lib/app/router.dart`
- Test: `test/features/settings/domain/settings_links_test.dart`
- Test: `test/features/settings/presentation/about_page_test.dart`

**Tests to write first:**
- `about page renders app name version and build`
- `privacy row navigates to legal privacy route`
- `terms row navigates to legal terms route`
- `DPO contact builds privacy request mailto`
- `footer points export correction and privacy requests to DPO email`

**Non-obvious implementation notes:**
- Use app version from a provider seam so tests do not depend on `package_info_plus`.
- Do not add an in-app export row.
- This step is 1-2 hours and build-green.

### Task 4.3: Add debug screen guarded by build flag

**Goal:** Provide debug-only diagnostics while preventing release-visible debug affordances.

**Files to create/edit:**
- Create: `lib/features/settings/presentation/pages/debug_settings_page.dart`
- Modify: `lib/features/settings/presentation/pages/about_page.dart`
- Modify: `lib/app/router.dart`
- Create: `test/tool/settings_release_guard_test.dart`
- Test: `test/features/settings/presentation/debug_settings_page_test.dart`

**Tests to write first:**
- `DEBUG_SETTINGS appears only in guarded settings files`
- `debug page is unavailable when flag is false`
- `about long press does not navigate when flag is false`
- `debug page renders wipe local data force resync entitlement and raw sync`
- `force resync calls sync engine seam`

**Non-obvious implementation notes:**
- Use `kDebugMode && bool.fromEnvironment('DEBUG_SETTINGS')`.
- Do not add live notification permission mocks beyond labels and provider seams.
- This step is 1-2 hours and build-green.

## Phase 5: Final Integration And Guardrails

### Task 5.1: Complete route and shell integration

**Goal:** Ensure Settings is the fourth bottom-nav tab and all detail routes are reachable without breaking existing route guards.

**Files to create/edit:**
- Modify: `lib/app/router.dart`
- Modify: `lib/features/shell/presentation/app_shell.dart` only if tab label/icon currently says More.
- Test: `test/features/shell/app_shell_test.dart`
- Test: `test/app/router_redirect_test.dart`

**Tests to write first:**
- `fourth shell branch is Settings`
- `settings detail routes build outside nested row placeholders`
- `pro route redirects are unchanged`
- `onboarding redirects are unchanged`

**Non-obvious implementation notes:**
- Do not add Spec 11 Progress tab work.
- If tab renaming is larger than expected, keep branch path `/more` but render Settings and add `/settings` redirect.
- This step is 1 hour and build-green.

### Task 5.2: Final docs and verification

**Goal:** Document parked work and prove the implementation does not cross spec boundaries.

**Files to create/edit:**
- Create or modify: `docs/superpowers/plans/2026-05-22-settings-account-plan.md` task checkboxes during execution.
- Modify: `test/tool/content_docs_test.dart` only if needed to include settings docs in attribution checks.

**Tests to write first:**
- `settings docs do not contain prohibited attribution strings`
- Existing guardrails: layering, sync/content boundary, paywall release guard, study-plan docs, settings release guard.

**Non-obvious implementation notes:**
- Commit each completed task separately.
- Final verification commands: `flutter test`, `flutter analyze`, `npm test --prefix functions` if functions dependencies are installed; otherwise report the exact blocker.
- This step is 1 hour and build-green.
