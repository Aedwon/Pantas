# Paywall Entitlement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build Spec 7's Android-only RevenueCat paywall, entitlement provider, Pro route gate, server-side entitlement enforcement seams, webhook unit coverage, and production validation checklist without syncing content or faking blocked live validations.

**Architecture:** The app gets a new `lib/features/paywall/` feature boundary for entitlement state, RevenueCat adapter seams, recommendation logic, paywall UI, and welcome/trial surfaces. RevenueCat and Firebase SDK calls stay behind fakeable gateways; `app.db` remains user data, `content.db` remains regenerable content and is never imported by sync or paywall persistence. Server trust is enforced through Firestore rules and Cloud Functions that check Firebase custom claims before Pro-gated reads.

**Tech Stack:** Flutter, Riverpod, GoRouter, RevenueCat `purchases_flutter`, Firebase Auth/Functions/Admin SDK seams, Firestore rules, Node 20 static/unit tests, Flutter widget/provider tests.

**Target spec:** `docs/superpowers/specs/2026-05-21-paywall-entitlement-design.md`

**Roadmap anchor:** `docs/superpowers/specs/2026-05-16-mvp-roadmap-design.md` Spec 7 - Paywall + RevenueCat + entitlement gate

**Date:** 2026-05-21

**Size:** L

---

## Open Questions

- Should the Settings subscription panel ship as a full Settings route now, or stay as a reusable panel widget until Spec 8 owns Settings IA? Tentative decision: build the panel widget and route stub integration only where it does not force Spec 8 scope.
- Should trial-end local push scheduling be implemented now if no notification scheduling seam exists yet? Tentative decision: implement a no-op `TrialReminderScheduler` interface and in-app banner logic only; leave local notification scheduling parked for Spec 9 rather than inventing infrastructure.
- Should anonymous purchase be linked to the Firebase anonymous UID at SDK login time on every boot or only when auth state changes? Tentative decision: configure RevenueCat on boot, then call `logIn(uid)` when an auth UID is available and changes.

## External Blockers

- **Skippable: RevenueCat dashboard project.** Create the RevenueCat Android project before live SDK validation.
- **Skippable: Google Play IAP products/subscriptions.** Create `pro_monthly`, `pro_yearly`, and `pro_lifetime`; configure the yearly 7-day trial in Play Console.
- **Skippable: RevenueCat product mappings, entitlement, and offering.** Map all three products to entitlement `pro` and expose the current offering.
- **Skippable: Android RevenueCat API key / dart-define.** Provide `--dart-define=REVENUECAT_ANDROID_API_KEY=...`; local tests use fake gateways and must not contain a real key.
- **Skippable: Firebase Functions deployment credentials.** Deploy webhook and Pro content functions only after Firebase CLI auth/project aliases are available.
- **Skippable: RevenueCat webhook shared secret.** Store `REVENUECAT_WEBHOOK_SECRET` through Firebase Functions secrets/config and set the same secret in RevenueCat.
- **Skippable: Play Internal Testing / license testers.** Upload an internal build and add tester accounts before end-to-end purchase validation.
- **Skippable: Firebase live custom-claim validation.** Validate webhook-driven `pro=true`/clear transitions against live Auth only after deployment and credentials exist.
- **Skippable: Sanity Pro-content live validation.** Validate Pro GROQ proxy against live Sanity only after Pro-tagged content exists and Function secrets are configured.
- **Skippable: Android manual QA.** Run purchase, restore, trial banner, network failure, route gate, transfer notification, and subscription panel scenarios on Android hardware.
- **Skippable: production verification.** Validate release build, release rules, webhook deployment, RevenueCat dashboard analytics filters, and Play purchase pipeline before launch.

## File Structure

- Create `lib/features/paywall/paywall.dart` as the feature barrel.
- Create `lib/features/paywall/domain/` for `Entitlement`, `PaywallPackage`, `PaywallOffering`, recommendation logic, CTA copy, trial banner state, and Pro welcome state.
- Create `lib/features/paywall/data/` for `RevenueCatGateway`, SDK adapter, `RevenueCatConfig`, subscription management link helpers, and no-op trial reminder scheduler seam.
- Create `lib/features/paywall/application/` for Riverpod providers over entitlement, offering, purchase/restore commands, welcome banner state, and route-gate decisions.
- Create `lib/features/paywall/presentation/` for `PaywallPage`, SKU cards, subscription panel, welcome banner, and inline Pro upgrade chip.
- Modify `lib/app/bootstrap.dart` and `lib/app/router.dart` for SDK boot and Pro route redirection to `/paywall`.
- Modify `firestore.rules` to add Pro-gated paths guarded by `request.auth.token.pro == true`.
- Modify `functions/src/` to add RevenueCat webhook helpers, claim transition helpers, and `getProContent` claim-gated callable/HTTPS seam.
- Add tests under `test/features/paywall/`, router tests under `test/app/`, static guardrails under `test/tool/`, and Functions tests under `functions/test/`.

## Phase 1: Boundaries, Domain Logic, And Guardrails

### Step 1.1: Add paywall boundary guardrails

**Goal:** Lock down Spec 7 layering and data-boundary constraints before production code lands.

**Files to create/edit:**
- Create: `test/tool/paywall_boundary_test.dart`
- Modify: `test/tool/sync_import_boundary_test.dart`
- Modify: `test/tool/firebase_rules_layout_test.dart`

**Tests to write first:**
- `paywall domain files do not import Flutter Riverpod Firebase RevenueCat Drift Dio or GoRouter`
- `only paywall RevenueCat gateway imports purchases_flutter`
- `sync module does not import paywall or content database`
- `firestore rules include Pro-gated paths guarded by the pro custom claim`

**Non-obvious implementation notes:**
- Use text-scanning guardrail patterns from `study_plan_boundary_test.dart`.
- Do not add `content.db` or Sanity client imports to paywall; Pro content fetch goes through Functions.
- Keep this step 1-2 hours and build-green.

### Step 1.2: Implement pure SKU recommendation and CTA copy

**Goal:** Compute the recommended SKU, pitch copy, and CTA copy from exam-date context and selected package.

**Files to create/edit:**
- Create: `lib/features/paywall/domain/paywall_package.dart`
- Create: `lib/features/paywall/domain/paywall_recommendation.dart`
- Create: `lib/features/paywall/paywall.dart`
- Test: `test/features/paywall/domain/paywall_recommendation_test.dart`

**Tests to write first:**
- `monthly is recommended when exam is less than five months away`
- `yearly is recommended from five to twenty four months`
- `yearly is recommended beyond twenty four months`
- `yearly is recommended when exam date is missing`
- `past exam date is treated as missing`
- `lifetime is never auto recommended`
- `CTA copy matches monthly yearly and lifetime selections`

**Non-obvious implementation notes:**
- Use stable SKU IDs: `pro_monthly`, `pro_yearly`, `pro_lifetime`.
- Recommendation logic must not hardcode RevenueCat package order except for the UI stable display order.
- Keep this step 1-2 hours and build-green.

### Step 1.3: Model entitlement, trial, and welcome states

**Goal:** Represent optimistic local entitlement state without depending on RevenueCat SDK types.

**Files to create/edit:**
- Create: `lib/features/paywall/domain/entitlement.dart`
- Create: `lib/features/paywall/domain/trial_notice.dart`
- Create: `lib/features/paywall/domain/pro_welcome.dart`
- Test: `test/features/paywall/domain/entitlement_test.dart`
- Test: `test/features/paywall/domain/trial_notice_test.dart`

**Tests to write first:**
- `free entitlement reports pro inactive`
- `active entitlement reports pro active with sku and expiration`
- `lifetime entitlement has no expiration and is active`
- `trial notice starts on day five and reports days remaining`
- `trial notice is hidden after conversion cancellation or expiration`
- `welcome state fires only on free to pro transition`

**Non-obvious implementation notes:**
- Keep purchase source strings as product IDs, not vendor-specific UI copy.
- Use injected clocks in tests; trial copy dates should be deterministic.
- Keep this step 1-2 hours and build-green.

## Phase 2: RevenueCat SDK Seam And Entitlement Providers

### Step 2.1: Add RevenueCat config and gateway interface

**Goal:** Configure Android-only RevenueCat through `--dart-define` and isolate SDK calls behind a fakeable gateway.

**Files to create/edit:**
- Create: `lib/features/paywall/data/revenuecat_config.dart`
- Create: `lib/features/paywall/data/revenuecat_gateway.dart`
- Test: `test/features/paywall/data/revenuecat_config_test.dart`
- Test: `test/features/paywall/data/revenuecat_gateway_contract_test.dart`

**Tests to write first:**
- `config is disabled when Android API key is missing`
- `config reads Android API key from dart define`
- `gateway contract exposes configure offerings purchase restore and customer info stream`
- `gateway maps current customer info into Entitlement without leaking SDK types`

**Non-obvious implementation notes:**
- Do not add iOS API key, StoreKit code, or App Store Connect branches.
- Production adapter is the only file allowed to import `purchases_flutter`.
- Keep this step 1-2 hours and build-green.

### Step 2.2: Add entitlement and offering Riverpod providers

**Goal:** Expose optimistic entitlement state, ordered offering packages, and fakeable purchase/restore commands to the app.

**Files to create/edit:**
- Create: `lib/features/paywall/application/paywall_providers.dart`
- Create: `lib/features/paywall/application/paywall_controller.dart`
- Test: `test/features/paywall/application/paywall_providers_test.dart`
- Test: `test/features/paywall/application/paywall_controller_test.dart`

**Tests to write first:**
- `entitlementProvider returns free when gateway has no cached info`
- `entitlementProvider returns Pro when cached entitlement is active`
- `offeringsProvider sorts packages monthly yearly lifetime`
- `purchase command refreshes entitlement after successful purchase`
- `restore command refreshes entitlement after restore`
- `purchase failure exposes sheet error without changing entitlement`

**Non-obvious implementation notes:**
- `FAKE_PRO` is allowed only under `kDebugMode && bool.fromEnvironment('FAKE_PRO')`.
- The provider must trust cached RevenueCat state; network refresh failure must not downgrade an active cached Pro state.
- Keep this step 2-3 hours and build-green.

### Step 2.3: Bootstrap RevenueCat and auth UID association

**Goal:** Initialize RevenueCat at app boot and associate the current Firebase UID when available.

**Files to create/edit:**
- Modify: `lib/app/bootstrap.dart`
- Modify: `lib/core/auth/providers.dart` only if a uid stream helper is needed.
- Modify: `lib/features/paywall/application/paywall_providers.dart`
- Test: `test/features/paywall/application/revenuecat_bootstrap_test.dart`

**Tests to write first:**
- `bootstrap skips RevenueCat when Android API key is absent`
- `bootstrap configures gateway when Android API key is present`
- `auth uid association calls logIn for anonymous and named UIDs`
- `same uid is not logged in repeatedly`

**Non-obvious implementation notes:**
- Do not force sign-in before purchase; anonymous UID association is valid for v1.
- Avoid live SDK initialization in tests; use a fake `RevenueCatGateway`.
- Keep this step 1-2 hours and build-green.

## Phase 3: Paywall UI, Restore, Subscription Panel, And In-App Notices

### Step 3.1: Build paywall package cards and screen

**Goal:** Render the single-screen paywall with stable SKU order, dynamic recommendation emphasis, restore link, and selection-aware CTA.

**Files to create/edit:**
- Create: `lib/features/paywall/presentation/paywall_page.dart`
- Create: `lib/features/paywall/presentation/paywall_package_card.dart`
- Test: `test/features/paywall/presentation/paywall_page_test.dart`

**Tests to write first:**
- `paywall renders Monthly Yearly Lifetime in stable order`
- `recommended package is selected by default`
- `yearly card always shows seven day free trial pill`
- `CTA changes when selected package changes`
- `restore link calls restore command`
- `purchase error renders offline-before-purchase copy and keeps sheet open`

**Non-obvious implementation notes:**
- Use `priceString` from package data; fallback fixture prices are only for tests and unavailable-offering state.
- Keep UI plain, coach-aligned, and Android-only; no StoreKit copy.
- Keep this step 2-3 hours and build-green.

### Step 3.2: Add inline Pro upgrade chip and welcome/trial banners

**Goal:** Provide reusable Pro trigger surfaces without implementing Spec 8/9 notification infrastructure.

**Files to create/edit:**
- Create: `lib/features/paywall/presentation/pro_upgrade_chip.dart`
- Create: `lib/features/paywall/presentation/pro_welcome_banner.dart`
- Create: `lib/features/paywall/presentation/trial_notice_banner.dart`
- Create: `lib/features/paywall/application/trial_reminder_scheduler.dart`
- Test: `test/features/paywall/presentation/pro_upgrade_chip_test.dart`
- Test: `test/features/paywall/presentation/pro_welcome_banner_test.dart`
- Test: `test/features/paywall/presentation/trial_notice_banner_test.dart`

**Tests to write first:**
- `upgrade chip opens paywall when tapped`
- `welcome banner renders once for free to pro transition`
- `trial notice banner appears from day five with charge date copy`
- `trial reminder scheduler no-ops when notification seam is unavailable`

**Non-obvious implementation notes:**
- Do not schedule local notifications unless a pre-existing notification scheduler seam exists; a no-op interface is the Spec 7 seam for Spec 9.
- Do not add confetti or payment-celebration copy.
- Keep this step 1-2 hours and build-green.

### Step 3.3: Add subscription status panel widget

**Goal:** Render subscription state and restore/manage actions as a reusable Settings-ready panel.

**Files to create/edit:**
- Create: `lib/features/paywall/presentation/subscription_panel.dart`
- Test: `test/features/paywall/presentation/subscription_panel_test.dart`

**Tests to write first:**
- `free panel shows Try Pro and Restore Purchases`
- `monthly panel shows renews date and manage action`
- `yearly trial panel shows days left and charge date`
- `lifetime panel shows yours forever and no manage action`
- `cancelled but active panel says ends date`

**Non-obvious implementation notes:**
- Open Play subscription management through an injected callback so tests do not launch URLs.
- Do not build the full Settings screen; Spec 8 owns final placement.
- Keep this step 1-2 hours and build-green.

## Phase 4: Router Gate And Feature Integration Seams

### Step 4.1: Replace paywall stub route and add Pro route redirect

**Goal:** Route `/paywall` to the real paywall and redirect Free users from Pro-only routes to `/paywall?returnTo=...`.

**Files to create/edit:**
- Modify: `lib/app/router.dart`
- Test: `test/app/router_redirect_test.dart`
- Test: `test/features/paywall/presentation/paywall_page_test.dart`

**Tests to write first:**
- `/paywall route builds real PaywallPage`
- `free user opening /plan/dossier/:mockId redirects to paywall`
- `pro user opening /plan/dossier/:mockId reaches dossier placeholder`
- `paywall receives returnTo query parameter`

**Non-obvious implementation notes:**
- Use a placeholder Pro dossier page only as an explicit Spec 7 route seam; do not implement Spec 11 progress features.
- Include `entitlementProvider` in router refresh dependencies.
- Keep this step 1-2 hours and build-green.

### Step 4.2: Wire Study Plan and Mock Exam Pro seams

**Goal:** Use the entitlement provider at existing Pro-depth seams without expanding Spec 6 or Spec 5 feature scope.

**Files to create/edit:**
- Modify: `lib/features/study_plan/presentation/home_plan_card.dart`
- Modify: `lib/features/study_plan/presentation/plan_page.dart` only if a Pro expand affordance already exists.
- Modify: `lib/features/mock_exam/presentation/pages/mock_results_page.dart`
- Test: `test/features/study_plan/presentation/home_plan_card_test.dart`
- Test: `test/features/mock_exam/presentation/mock_results_page_test.dart`

**Tests to write first:**
- `free study plan Pro depth tap shows inline upgrade chip`
- `pro study plan Pro depth tap opens depth content seam`
- `free mock results render dossier preview upgrade prompt`
- `pro mock results render per-question review`

**Non-obvious implementation notes:**
- Existing mock result tests already pass explicit `proIsActive`; prefer adding provider-level seams only where the widget is already Consumer-based.
- Do not implement Spec 11 analytics/progress pages.
- Keep this step 2-3 hours and build-green.

## Phase 5: Firebase Rules, RevenueCat Webhook, And Pro Content Proxy

### Step 5.1: Add Firestore Pro rules and static guardrails

**Goal:** Deny Free users from Pro-gated Firestore paths and require `request.auth.token.pro == true` for Pro content reads.

**Files to create/edit:**
- Modify: `firestore.rules`
- Modify: `test/tool/firebase_rules_layout_test.dart`

**Tests to write first:**
- `firestore.rules gates user proDossiers by owner and pro claim`
- `firestore.rules gates examTracks proContent by pro claim`
- `firestore.rules keeps audit logs denied`
- `firestore.rules does not allow anonymous Pro reads`

**Non-obvious implementation notes:**
- Static tests run without Firebase emulator credentials; live rules-unit-testing remains parked until external setup unblocks.
- Do not add content rows to user sync collections.
- Keep this step 1 hour and build-green.

### Step 5.2: Add RevenueCat webhook helpers and claim transitions

**Goal:** Verify signed webhook requests, deduplicate events, rate-limit per UID, and map RevenueCat events to Firebase Auth custom claim changes.

**Files to create/edit:**
- Create: `functions/src/revenuecatWebhook.ts`
- Create: `functions/src/revenuecatClaims.ts`
- Modify: `functions/src/index.ts`
- Test: `functions/test/revenuecat-webhook.test.mjs`
- Modify: `functions/test/static.test.mjs`

**Tests to write first:**
- `missing webhook authorization is rejected with 401`
- `invalid webhook authorization is rejected with 401`
- `valid signature is accepted`
- `initial purchase renewal product change and incoming transfer set pro true`
- `cancellation expiration and outgoing transfer clear pro`
- `duplicate event id is a no op`
- `per uid rate limit returns 429 after thirty events per minute`

**Non-obvious implementation notes:**
- Use Node `crypto.createHmac('sha256', secret)` over the raw body for local unit tests and keep the signature parser isolated.
- Admin SDK calls should be wrapped in small functions so tests can inspect pure transition behavior without live Firebase.
- Keep this step 2-3 hours and build-green.

### Step 5.3: Add Pro content callable/HTTPS proxy seam

**Goal:** Provide a server-side Pro content fetch path that checks Firebase custom claims before issuing Pro-tagged Sanity queries.

**Files to create/edit:**
- Create: `functions/src/getProContent.ts`
- Modify: `functions/src/index.ts`
- Test: `functions/test/pro-content.test.mjs`
- Modify: `test/tool/content_docs_test.dart` if docs need the Pro-content amendment checked.

**Tests to write first:**
- `getProContent rejects unauthenticated requests`
- `getProContent rejects authenticated requests without pro claim`
- `getProContent allows authenticated pro claim`
- `getProContent source does not expose Sanity token literals`

**Non-obvious implementation notes:**
- Do not call live Sanity in tests; validate claim gates and request shape only.
- Keep direct public free-content CDN behavior unchanged; only Pro-tagged content must go through Functions.
- Keep this step 1-2 hours and build-green.

## Phase 6: Release Defenses, Docs, And Final Verification

### Step 6.1: Add `FAKE_PRO` release defense and attribution guardrail

**Goal:** Allow debug-only Pro UI testing while blocking release builds that expose the flag or vendor/model attribution strings.

**Files to create/edit:**
- Create: `test/tool/paywall_release_guard_test.dart`
- Modify: `lib/features/paywall/application/paywall_providers.dart`
- Test: `test/tool/paywall_release_guard_test.dart`

**Tests to write first:**
- `FAKE_PRO appears only in debug guarded paywall provider code`
- `paywall files do not contain tool model or vendor attribution strings`
- `release scan command is documented for CI without running a release build locally`

**Non-obvious implementation notes:**
- The real release APK grep is parked until Android signing/build setup is available; keep a static local guard now.
- Do not add attribution strings anywhere in app copy, comments, docs, or test fixtures.
- Keep this step 1 hour and build-green.

### Step 6.2: Document parked live validation and manual QA

**Goal:** Record exact external actions that remain blocked after local implementation.

**Files to create/edit:**
- Create: `docs/superpowers/plans/2026-05-21-paywall-live-validation.md`
- Modify: `docs/superpowers/plans/2026-05-21-paywall-entitlement-plan.md`
- Test: `test/tool/paywall_docs_test.dart`

**Tests to write first:**
- `paywall live validation doc lists RevenueCat dashboard project`
- `paywall live validation doc lists Google Play IAP products`
- `paywall live validation doc lists Firebase live custom claim validation`
- `paywall live validation doc lists Sanity Pro content live validation`
- `paywall live validation doc lists Android manual QA`

**Non-obvious implementation notes:**
- Be explicit that live RevenueCat, Google Play, Firebase, and Sanity validations are not complete until manually performed.
- Do not include secrets, project keys, or dashboard URLs that are not known.
- Keep this step 1 hour and build-green.

### Step 6.3: Final full verification

**Goal:** Prove local implementation is green and report blocked external work honestly.

**Files to create/edit:**
- No production files unless verification reveals a bug.

**Tests to write first:**
- No new tests; run the full local verification suite.

**Non-obvious implementation notes:**
- Run `flutter test`.
- Run `flutter analyze`.
- Run `npm test --prefix functions`.
- Run any focused guardrails that are not included in `flutter test`.
- Do not claim live RevenueCat, Play, Firebase, or Sanity success without real external validation.
- Keep this step build-green; fix local failures before reporting.
