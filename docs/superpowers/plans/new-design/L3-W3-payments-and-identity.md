# L3 W3: payments and identity (implementation plan)

Level 3. Date: October 6, 2026. Author: lead. Policy revision: origin/main 9d2c0b5f.
Level 2 plan: `L2-W3-payments-and-identity.md`; tier spec (approved Oct 6). Base: integration branch
after W0 integrates (needs the exam catalog). Executor and reviewer: Opus (B7: payments,
entitlement). Own worktree. Closes carry-forward N3-8, N-19, N-23.

Router edits (gate L3-1): Tasks 3 and 8 change `lib/app/router.dart` (`_settingsEntitlement`, the
`proIsActive` reads). W1 Task 7 splits that file in parallel, so W3 makes those edits last: after W1
integrates, rebase onto the integration branch, edit the file W1 left (`router.dart` or the route
file the entry moved to), then run `flutter test test/app` (green). Until then, Tasks 3 and 8 change
only paywall files and their tests.
Prerequisites Aedwon provides before the named tasks run (requested with the start of level 4):
- P1 RevenueCat secret API key stored as a Functions secret `REVENUECAT_SECRET_API_KEY` (Task 2).
- P2 Play Console and RevenueCat: the four Civil Service products, trial moved to Monthly with "new
  customers only, across all subscriptions", price points confirmed (Tasks 4 and 7 integration).
- P3 Exam dates with source links in `content/exams/catalog.yaml` (W0) for pass tests on real data.
- P4 Approval to deploy functions and Firestore rules (Task 10 deploy step only).
Without a prerequisite, its task stops at the tested code and reports.

Facts from the Oct 6 inventory: no Apple sign-in exists (the public ID is for Google accounts; the
"or Apple" wording waits for Apple sign-in); `proIsActive` has 113 lib references, two getter
definitions (`entitlement.dart:48`, `revenuecat_sdk.dart:48`) and two independent flags
(`MockEntitlementSnapshot.proIsActive`, `RoadmapInputs.proIsActive`); functions tests in `.ts` and
`*.rules.mjs` are not run by `npm test`.

Every task: failing test first, confirm the failure reason, smallest code, task checks, commit.

## Task 1. Functions test runner covers every test

Change `functions/package.json` so `npm test` runs `test/*.test.mjs`, the `.ts` behavior tests and the
rules tests (emulator). Test: a deliberately failing assertion in each file type fails the run, then
is removed. Checks: `npm test` in `functions/` green.

## Task 2. Cancellation keeps Pro until expiry

Traceability: R-4.

1. Reproduce: write failing tests for "Pro stays after CANCELLATION until expiry" at each layer:
   webhook policy (`revenuecatPolicy.ts`), client gateway (`live_revenuecat_gateway.dart`
   `_acceptCustomerInfo`, `entitlementFromCustomerInfo`), snapshot store, and the claim reader
   (`sync_claim_gateway.dart`). The layer that clears early is the root cause; record which.
2. Webhook (balanced, Oct 4): for CANCELLATION, UNCANCELLATION, EXPIRATION, BILLING_ISSUE,
   PRODUCT_CHANGE, TRANSFER_* and NON_RENEWING_PURCHASE, call RevenueCat's subscriber endpoint with
   P1 and set the claim from the active entitlements. Ignore an event whose `event_timestamp_ms` is
   older than the last applied one for that user (out-of-order). On RevenueCat failure return 500
   so RevenueCat retries; count the rate limit once per event id, not per retry.
Files: `functions/src/revenuecatPolicy.ts`, `revenuecatClaims.ts`, `revenuecatWebhook.ts`, new
`functions/src/revenuecatSubscriber.ts`, the client files where the root cause is.
Tests: functions tests for every event type and the failure path; Dart gateway tests.
Checks: `npm test` in `functions/` green (Task 1's runner, so `.ts` and rules tests run); `flutter test test/features/paywall` green.

## Task 3. Entitlement model

Traceability: S0-35, G-f-12 to G-f-16, G-f-31 (logic; W4f Task 6 draws them).

Extend `Entitlement` (`lib/features/paywall/domain/entitlement.dart`) with `tier`, `passes`
(exam id to end date), `state` (`free`, `trial`, `active`, `canceledActive`, `billingIssue`,
`grant`, `unknown`), `endsAt`, `renewsAt`, `chargesAt`, `coversExam(examId)`, `mockLimit(examId)`
(unlimited when covered, else one per 14 days per exam with `nextMockOpensAt`). Extend
`RevenueCatCustomerInfoSnapshot` for several active products, non-subscription purchases and
`billingIssuesDetectedAt`. `EntitlementSnapshotStore` persists the new fields and reads old snapshots.
Handle every exhaustive `switch` on `EntitlementPlan` (router `_settingsEntitlement`, `pro_page.dart`,
`subscription_panel.dart`, `entitlement_snapshot_store.dart`, `live_revenuecat_gateway.dart`).
Tests first: `coversExam` for tier inclusion (Civil Service covers Student exams), pass scope (one
exam), expired pass, grant, unknown plan; `mockLimit`; snapshot round trip and old-snapshot read.
Checks: `flutter test test/features/paywall test/features/settings` green.

## Task 4. Tiers and products

`PriceTier` and `tierForExam` from W0's `ExamCatalogRepository`; one product table
`lib/features/paywall/domain/products.dart` mapping each id (`pantas_pro_weekly`, `_monthly`,
`_yearly`, `pantas_cs_weekly`, `_monthly`, `_yearly`, `pantas_pass_civil_service`) to tier, period
and kind; the gateway reads it instead of private constants, so the CS ids are not "unrecognized".
Remove hard-coded prices and the Yearly-trial assumption from `paywall_recommendation.dart` (the
recommendation itself is retired, S0-24; W4f Task 7 deletes the file).
Tests first: every product id maps; unknown id stays `unknown`; no `₱` literal remains in
`lib/features/paywall/domain` or `data` (test greps).
Checks: `flutter test test/features/paywall` green.

## Task 5. Season Pass end dates

Webhook on NON_RENEWING_PURCHASE: read the exam id from purchase metadata, compute `endsAt` from
`functions/src/examCatalog.json` (last day of the first sitting on or after purchase), write
`users/{uid}/passes/{examId}` and mirror `passes` into the custom claims. A pass for an exam with no
future sitting is recorded with `endsAt: null` and an audit entry for Aedwon (the app never offers
it; tier spec decision 1). N3-8: a later catalog date reaches passes through a new export, a
functions deploy (P4) and `recomputePassEnds`, an admin-only function that recomputes affected
passes, never moving an end earlier (D-227). Tests: purchase records the pass; moved-later date
recomputes; moved-earlier keeps the original; no sitting gives null and an audit entry.
Checks: `npm test` in `functions/` green (Task 1's runner, so `.ts` and rules tests run).

## Task 6. Switching rule

`switchOutcome(from, to, entitlement)` in `lib/features/paywall/domain/switch_outcome.dart`:
`keepsPro`, `upgradeOffer(plans)` (no trial, with Switch on Free), `passWarning`, `free`.
Tests first: one case per switching board (ST_SwitchUpgrade, ST_SwitchPassWarn, same tier, lower
tier, Free student).
Season Pass bought by an active Student subscriber (gate L3R2-6): Play replacement modes do not
apply to one-time products, so the Student plan keeps renewing. Lead default, for Aedwon to confirm
at the start of level 4 (tier spec: nobody pays twice): after the pass purchase, the Pro page shows
that the Student plan still renews, with Manage in Google Play (`manage()`); nothing cancels
automatically. The copy needs his approval (no board draws it). Test: the outcome carries
`studentPlanStillRenews`. If he chooses otherwise, stop and re-plan this case.
Checks: `flutter test test/features/paywall` green.

## Task 7. Purchase operations and trial eligibility

Map `PaymentOperationStatus` (11 values) to the six typed results (`success`, `pending`,
`offline`, `cancelled`, `storeError`, `notConfirmedYet`); add `pending` from the SDK's pending
purchase state; nothing can be bought twice while pending. Upgrade uses `WITH_TIME_PRORATION` for every Student to Civil Service pair
(N-19, settled Oct 6 from developer.android.com/google/play/billing/subscriptions: it applies to
upgrades and downgrades and credits the remaining time by moving the next billing date;
`CHARGE_PRORATED_PRICE` works only where the price per unit of time rises, which fails for pairs
such as Student Weekly ₱29 to Civil Service Yearly ₱1,199). If the ST_SwitchUpgrade copy promises
an immediate charge of the difference, stop and ask the lead. `manage()` opens Play's subscription page.
Trial shown only when RevenueCat reports the Monthly intro offer eligible.
Tests: mapping table; pending blocks a second purchase; eligibility display.
Checks: `flutter test test/features/paywall` green.

## Task 8. Active exam in every Pro gate (N-23)

Add `proForActiveExamProvider` (combines `entitlementProvider` and `activeExamFocusProvider`; true
when `coversExam(activeExam)`). Getters: `Entitlement.proIsActive` (`entitlement.dart:48`) stays the
any-plan flag; `RevenueCatCustomerInfoSnapshot.proIsActive` (`revenuecat_sdk.dart:48`) stays
data-layer only. Neither is read by a gate after W4. Call sites on 1f79d880 and their owners
(gate L3R2-5):
- W3 (this task): `MockEntitlementSnapshot` (`mock_availability.dart`,
  `mock_availability_provider.dart`), `RoadmapInputs` (`roadmap_inputs.dart`, `roadmap_inputs_reader.dart`,
  `mock_day.dart`), and the route builders in `router.dart` (after W1 integrates; they are then in
  `quiz_routes.dart` and `mock_routes.dart`).
- Keep the any-plan flag: `settings_providers.dart` (Settings label), `sync_runtime_bootstrap.dart`
  and `bootstrap.dart` (sync eligibility), `live_revenuecat_gateway.dart`, `paywall_controller.dart`,
  `pro_welcome.dart`, `trial_notice.dart` (paywall internals).
- Each W4 family switches its own screens to the new provider: W4b (`tendencies_panel.dart` and the
  rebuilt performance and plan screens), W4d (`quiz_page.dart`, `debrief_*`, `flagged_list_page.dart`,
  `quiz_results_page.dart`), W4e (`mock_results_page.dart`, `mock_results_route.dart`,
  `mock_review_page.dart`, `mock_panel.dart` successors), W4f (`pro_page.dart` and the Settings Pro
  row), W4g (Wrapped history gate). W2's `review_list.dart` and `answer_reveal.dart` take a flag; the
  calling family passes the new provider's value.
Keep the debug `FAKE_PRO` and `devProOverrideProvider` behavior (guarded by
`test/tool/paywall_release_guard_test.dart`). Tests: switching the active exam from a Student exam
to CSE with Student Pro turns the gate off; with CS Pro both stay on.
Checks: `flutter test test/features/paywall` green; `flutter test test/features/mock_exam test/features/roadmap test/tool/paywall_release_guard_test.dart` green.

## Task 9. Trial-ending trigger

Traceability: S0-25, G-f-22.

Replace `trial_reminder_scheduler.dart` (no callers) with
`lib/features/paywall/application/trial_ending_notifier.dart`: interface `TrialEndingNotifier`
(`schedule(DateTime chargeAt, String priceText)`, `cancel()`), a no-op binding, and
`TrialEndingScheduler.sync(entitlement)` calling it 24 hours before `chargesAt`, cancelling on
cancel or conversion. Update the paywall barrel. Tests: schedule, reschedule on date change, cancel.
Checks: `flutter test test/features/paywall` green.

## Task 10. Short public ID

Traceability: R-5 (UI is W4f Task 8).

Functions: `functions/src/publicId.ts` (`ensurePublicId`, called from `recordSignInEvent` on first
Google sign-in; random 9 digits with a check digit, not derived from the uid; transaction for
uniqueness), `functions/src/publicIdAdmin.ts` (admin-only lookup with audit log), deletion in
`deleteAccount.ts` before `deleteUser` (mapping removed, id retired in a `retiredPublicIds`
collection), export includes the id. Rules: mapping collection client-denied; the user's own id
readable only by its owner; no client write. Dart: `publicIdProvider` in
`lib/core/auth/public_id_provider.dart` (states `notSignedIn`, `notReady`, `ready(digits)`) and a
check-digit validator sharing a test-vector file with the TS one
(`test/fixtures/public_id_vectors.json`).
Privacy text: the ID must be covered (giveaways log); the lead drafts the added sentences for
Aedwon's approval before they go into `lib/features/legal/domain/legal_document.dart` (legal copy).
Tests: rules (owner read, no client write, mapping denied), concurrent creation uniqueness, check
digit vectors, anonymous gets none, deletion retires, export contains it.
Deploy (P4) after review.
Checks: `npm test` in `functions/` green (Task 1's runner, so `.ts` and rules tests run); `flutter test test/core/auth` green.

## Task 11. Full checks, review, integration

All required checks plus `npm test` in `functions/`; evidence in `evidence/W3.md`; independent Opus
code review; lead integrates. Report to Aedwon: the external setup checklist status (P1 to P4).
