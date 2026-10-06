# L3 W3: payments and identity (implementation plan)

Level 3. Date: October 6, 2026. Author: lead. Policy revision: origin/main 9d2c0b5f.
Level 2 plan: `L2-W3-payments-and-identity.md`; tier spec (approved Oct 6). Base: integration branch
after W0 integrates (needs the exam catalog). Executor: GPT-6.1 Sol High through Codex; audit:
GPT-6 Astra; the Opus lead reviews and accepts every money and entitlement change (strategy B7 as
amended October 6). Own worktree. Functions tasks (2, 5, 10, 13, 14, 15) start after W6 Task 1
integrates (its package and test runner). Closes carry-forward N3-8, N-19, N-23.

Router edits (gate L3-1): Tasks 3 and 8 change `lib/app/router.dart` (`_settingsEntitlement`, the
`proIsActive` reads). W1 Task 7 splits that file in parallel, so W3 makes those edits last: after W1
integrates, rebase onto the integration branch, edit the file W1 left (`router.dart` or the route
file the entry moved to), then run `flutter test test/app` (green). Until then, Tasks 3 and 8 change
only paywall files and their tests.
Prerequisites Aedwon provides before the named tasks run (requested with the start of level 4):
- P1 RevenueCat secret API key (V2, read-only customer access) stored as a Functions secret
  `REVENUECAT_SECRET_API_KEY` in pantas-staging and pantas-prod, plus the RevenueCat project id as a
  plain setting `REVENUECAT_PROJECT_ID` (Task 2). Aedwon's steps: `level4-setup-steps.md` Part 5.
- P2 Play Console and RevenueCat: the four Civil Service products, trial moved to Monthly with "new
  customers only, across all subscriptions", price points confirmed (Tasks 4 and 7 integration).
- P3 Exam dates with source links in `content/exams/catalog.yaml` (W0) for pass tests on real data.
- P4 Approval for each deploy step in Task 15.
Without a prerequisite, its task stops at the tested code and reports.

Facts from the Oct 6 inventory: no Apple sign-in exists (the public ID is for Google accounts; the
"or Apple" wording waits for Apple sign-in); `proIsActive` has 113 lib references, two getter
definitions (`entitlement.dart:48`, `revenuecat_sdk.dart:48`) and two independent flags
(`MockEntitlementSnapshot.proIsActive`, `RoadmapInputs.proIsActive`); functions tests in `.ts` and
`*.rules.mjs` are not run by `npm test`.

Every task: failing test first, confirm the failure reason, smallest code, task checks, commit.
Abuse cases: L2 W3 §10 AC-1 to AC-11 (abuse review 1, level 2 gate passed at review 7); each task
names the AC ids it closes and its tests are named after them.

## Task 1. Rebase onto W6's Functions package

W6 Task 1 owns `functions/package.json`, the build and the test runner (moved from this plan,
Oct 6). Rebase onto the integration branch after W6 Task 1 lands; confirm `npm ci && npm run build
&& npm test` in `functions/` exit 0 before Task 2. Checks: those three commands exit 0.

## Task 2. Webhook: reconcile current state (R-4, AC-2, AC-3)

Traceability: R-4, X-5, X-6, X-16.

1. Reproduce: failing tests for "Pro stays after CANCELLATION until expiry" at each layer: webhook
   policy (`revenuecatPolicy.ts`), client gateway (`live_revenuecat_gateway.dart`
   `_acceptCustomerInfo`, `entitlementFromCustomerInfo`), snapshot store, claim reader
   (`sync_claim_gateway.dart`). Record which layer clears early.
2. Every event type triggers reconciliation: read the customer's current state from RevenueCat's REST
   API v2 (check the current v2 reference for paths; confirm it returns a request time and a
   sandbox flag per purchase) with P1. Keep from each event and answer: app id, environment,
   product ids, entitlement ids, expiry. Act only for the Pantas app id; count production purchases
   of products in the product table (Task 4), and sandbox purchases only in pantas-staging or for
   uids on the server-only tester allowlist `config/testers` in pantas-prod (each logged).
3. Refuse a signed request older than 5 minutes; first confirm how RevenueCat signs retries and
   widen the limit if retries keep the original time (record in evidence).
4. In one Firestore transaction per user: dedupe the event id, refuse a write whose RevenueCat answer
   time is older than the stored one, set the claims `pro` and `proUntil` (milliseconds: latest end
   of active known subscriptions, ledger passes and `promo_*` entitlements, plus 1 day), and set
   `claimsChangedAt` on `users/{uid}`. On RevenueCat failure return 500 so RevenueCat retries.
5. Rules: sync and server reads require `request.auth.token.pro == true &&
   request.auth.token.proUntil > request.time.toMillis()`; `users/{uid}` stays owner-readable.
6. App: refresh the ID token when `claimsChangedAt` changes, after every purchase and restore, and
   once after a permission-denied sync.
Files: `functions/src/revenuecatPolicy.ts`, `revenuecatClaims.ts`, `revenuecatWebhook.ts`, new
`functions/src/revenuecatSubscriber.ts`, `firestore.rules` (Pro predicates only, after W6's rule
changes), `lib/core/sync/eligibility/sync_claim_gateway.dart`, the client files where the root
cause is.
Tests (AC-2, AC-3): every event type reconciles; sandbox event in prod ignored unless allowlisted;
unknown product ignored; late event after expiry does not restore Pro; concurrent events commit in
answer-time order; replayed event is a no-op; stale signature refused; missing `proUntil` denied by
rules; RevenueCat failure returns 500; token refresh on `claimsChangedAt`.
Checks: `npm test` in `functions/` green (W6's runner, emulators included); `flutter test test/features/paywall test/core/sync` green.

## Task 3. Entitlement model

Traceability: S0-35, G-f-12 to G-f-16, G-f-31 (logic; W4f Task 6 draws them).

Extend `Entitlement` (`lib/features/paywall/domain/entitlement.dart`) with `tier`, `passes`
(exam id to end date, from the pass ledger only, Task 5), `state` (`free`, `trial`, `active`, `canceledActive`, `billingIssue`,
`grant`, `unknown`, `paused` (set by Task 11)), `endsAt`, `renewsAt`, `chargesAt`, `coversExam(examId)`, `mockLimit(examId)`
(unlimited when covered, else one per 14 days per exam with `nextMockOpensAt`). Extend
`RevenueCatCustomerInfoSnapshot` for several active products, non-subscription purchases and
`billingIssuesDetectedAt`. `EntitlementSnapshotStore` persists the new fields and reads old snapshots.
Handle every exhaustive `switch` on `EntitlementPlan` (router `_settingsEntitlement`, `pro_page.dart`,
`subscription_panel.dart`, `entitlement_snapshot_store.dart`, `live_revenuecat_gateway.dart`).
`coversExam` uses Task 13's coverage rule.
Tests first: `coversExam` for tier inclusion (Civil Service covers Student exams), pass scope (one
exam), expired pass, grant, unknown plan; `mockLimit`; snapshot round trip and old-snapshot read.
Checks: `flutter test test/features/paywall test/features/settings` green.

## Task 4. Tiers and products

`PriceTier` and `tierForExam` from W0's `ExamCatalogRepository`; one product table
`lib/features/paywall/domain/products.dart` mapping each id (`pantas_pro_weekly`, `_monthly`,
`_yearly`, `pantas_cs_weekly`, `_monthly`, `_yearly`, `pantas_pass_civil_service`) to tier, period
and kind, and each promotional entitlement (`promo_student`, `promo_civil_service`) to its tier
(AC-7); the same table is exported to `functions/src/products.json` for the server; the gateway reads it instead of private constants, so the CS ids are not "unrecognized".
Remove hard-coded prices and the Yearly-trial assumption from `paywall_recommendation.dart` (the
recommendation itself is retired, S0-24; W4f Task 7 deletes the file).
Tests first: every product id maps; unknown id stays `unknown`; no `₱` literal remains in
`lib/features/paywall/domain` or `data` (test greps).
Checks: `flutter test test/features/paywall` green.

## Task 5. Pass ledger and end dates (AC-4)

Traceability: X-3, X-4.

1. Confirm the RevenueCat mechanism that binds the chosen exam id to a non-subscription
   transaction (purchase metadata or an attribute read back with the transaction) and the signal
   for a refunded non-subscription purchase. If either is missing, stop and ask the lead (fallbacks:
   one pass product per exam; a daily reconciliation job against RevenueCat's purchase list).
2. Webhook, inside Task 2's transaction: write `users/{uid}/passes/{transactionId}` with `examId`,
   product, sitting, `endsAt` (last day of the first sitting on or after purchase, from
   `functions/src/examCatalog.json`), state `active`. Reject an exam the product does not allow
   (`pantas_pass_civil_service`: CSE Professional, CSE Subprofessional). No future sitting: write
   nothing that grants and log an audit entry for Aedwon. Refund or revocation sets `revoked`;
   transfer moves the record; a duplicate delivery is a no-op.
3. N3-8: a later catalog date reaches passes through a new export, a functions deploy and
   `recomputePassEnds` (admin-only via W6's `requireAdmin`), never moving an end earlier (D-227).
4. Rules: clients read their own pass records and never write them. The app's `passes` map comes
   from these records only.
Tests (AC-4): purchase records a pass; wrong exam rejected; refund revokes; duplicate is a no-op;
transfer moves; moved-later date recomputes; moved-earlier keeps the original; no sitting grants
nothing; client write denied.
Checks: `npm test` in `functions/` green.

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
  `mock_day.dart`), the mock entitlement wiring in `bootstrap.dart` (the override that builds
  `MockEntitlementSnapshot`; `features/mock_exam` cannot import `features/paywall`), and the route
  builders in `router.dart` (after W1 integrates; they are then in
  `quiz_routes.dart` and `mock_routes.dart`).
- Keep the any-plan flag (plan status, not gates): `settings_providers.dart` (`proRowValueProvider`,
  the Settings Pro row), `pro_page.dart` (plan name, Your plan rows and the direct Manage link only; whether the
  page offers its tier's plans and pass or shows the owned state follows `proForActiveExamProvider`,
  built by W4f Task 6),
  `sync_runtime_bootstrap.dart` (sync eligibility), `live_revenuecat_gateway.dart`, `paywall_controller.dart`,
  `pro_welcome.dart`, `trial_notice.dart` (paywall internals).
- Each W4 family switches its own gates to the new provider: W4b (`tendencies_panel.dart`,
  `how_you_work_page.dart`, `why_you_miss_section.dart` successors, and the rebuilt performance and
  plan screens), W4d (`quiz_page.dart`, `debrief_page.dart` including its direct
  `entitlementProvider` read, `debrief_providers.dart`, `session_debrief.dart`,
  `flagged_list_page.dart`, `quiz_results_page.dart`), W4e (`mock_results_page.dart`,
  `mock_results_route.dart`, `mock_review_page.dart`, `mock_panel.dart` successors), W4g (Wrapped
  history gate). W4f's only active-exam read is the Pro page's offer-or-owned choice; its plan status keeps the
  any-plan flag above. `router.dart` `_isProRoute` and
  the `/review` builder go with W1 Task 7. W2's `review_list.dart` and `answer_reveal.dart` take a flag; the
  calling family passes the new provider's value.
Keep the debug `FAKE_PRO` and `devProOverrideProvider` behavior (guarded by
`test/tool/paywall_release_guard_test.dart`). Tests: switching the active exam from a Student exam
to CSE with Student Pro turns the gate off; with CS Pro both stay on.
Update `test/app/mock_entitlement_override_test.dart` for the active-exam override.
Checks: `flutter test test/features/paywall` green; `flutter test test/features/mock_exam test/features/roadmap test/app test/tool/paywall_release_guard_test.dart` green.

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
collection); the public ID is included in the manual DPO export (W6 disables `exportData`). Rules: mapping collection client-denied; the user's own id
readable only by its owner; no client write. Dart: `publicIdProvider` in
`lib/core/auth/public_id_provider.dart` (states `notSignedIn`, `notReady`, `ready(digits)`) and a
check-digit validator sharing a test-vector file with the TS one
(`test/fixtures/public_id_vectors.json`).
Privacy text: the ID must be covered (giveaways log); the lead drafts the added sentences for
Aedwon's approval before they go into `lib/features/legal/domain/legal_document.dart` (legal copy).
Order: W6's `recordSignInEvent` audit limit lands first; `ensurePublicId` always runs.
Tests: rules (owner read, no client write, mapping denied), concurrent creation uniqueness, check
digit vectors, anonymous gets none, deletion retires. Deploy: Task 15.
Checks: `npm test` in `functions/` green (W6's runner); `flutter test test/core/auth` green.

## Task 11. Offline window and trusted time (AC-1, AC-6)

Traceability: X-2, X-9. Aedwon: 3-day window and the paused line "Connect once to keep using Pro."
(Oct 6).

New `lib/features/paywall/application/offline_window.dart` and `trusted_clock.dart`, used by
`entitlementProvider`, the gateway and `entitlement_snapshot_store.dart`:
- Cached Pro is the app's own last confirmed entitlement (snapshot store), never the SDK cache. It
  holds until its `expiresAt` (subscription, ledger pass or promotional grant) plus 3 days of
  effective time without a successful check; then `state = paused` and `coversExam` is false.
- Successful check: entitlement verification `verified` (turn on RevenueCat trusted entitlements;
  `verifiedOnDevice`, `notRequested` and failures never count) and `requestDate` strictly later than
  the stored trusted time. A verified inactive answer revokes only when its `requestDate` is newer
  than the active evidence held. The stored trusted time never moves backward.
- Effective time: the latest of the device clock, the mark, and the last trusted time plus the
  elapsed time since it in the same boot (Android `SystemClock.elapsedRealtime()` through a small
  platform channel; on iOS the equivalent continuous clock, or the boot detector is skipped with a
  logged warning, never a crash).
- Backward steps: in-session reading-to-reading drops, and at each start a boot wall time (device
  clock minus elapsed time) earlier than the stored one by more than 2 seconds in the same boot (a
  lower elapsed time means a new boot). Start-up runs the boot detector first and marks the step
  seen, so each setback counts once. A running total over 10 minutes uses up the window.
- A successful check resets the mark to the trusted time and clears the total. While paused, or
  after a counted step, with the network up, call `invalidateCustomerInfoCache()` before
  `getCustomerInfo()`.
- The mark, trusted time and boot records belong to the device and survive sign-out.
Tests (AC-1, AC-6): the eight named in L2 W3 AC-1 (a cached answer does not reset; `verifiedOnDevice`
does not count; repeated small setbacks pause; an in-session setback counts; a wrong-year clock
corrected then online unpauses; a closed-app setback in the same boot counts once; a reboot then an
ordinary start does not pause; RevenueCat down after the cache is cleared keeps Pro from the
snapshot inside the window), plus paused at the window end and unpaused by one check.
Checks: `flutter test test/features/paywall` green.

## Task 12. Account switch and restore (AC-5, AC-11)

Traceability: X-8.

On sign-out, account switch and deletion: clear the snapshot store and in-memory entitlement, call
RevenueCat `logOut` or `logIn` for the new uid before any Pro read, and block purchases until it
returns. Files: `lib/core/sync/local_state_wiper.dart`, `lib/core/auth/auth_repository.dart`,
`lib/features/paywall/application/revenuecat_bootstrap.dart`. RevenueCat's restore behavior stays
"Transfer to new App User ID" (record the dashboard setting in evidence).
Tests (AC-5, AC-11): a second account on the same phone sees Free offline; purchase blocked until
the identity is set; a restore on a second account moves Pro (TRANSFER, Task 2).
Checks: `flutter test test/features/paywall test/core/sync test/core/auth` green.

## Task 13. Coverage rule and giveaways (AC-7, AC-9)

Traceability: X-11, X-19.

One coverage rule for app and server with shared test vectors (`test/fixtures/coverage_vectors.json`,
read by the Dart and TS tests): the union of active subscriptions of products in the product table,
active ledger passes, and active `promo_student` and `promo_civil_service` entitlements (Civil
Service includes Student). Anything unknown adds nothing and is logged; `state = unknown` only when
nothing known is active. A non-subscription purchase in RevenueCat's lists never grants by itself.
Trial: shown only when RevenueCat returns the Monthly free-trial offer for the product (Android
subscription options; Google's rule, Aedwon Oct 6).
Tests (AC-7, AC-9): vectors for each tier, pass scope, `promo_*`, a `pro` grant with no known
product (no coverage), an old or refunded pass in the purchase list (no coverage), unknown plus
known (known wins), trial offer present or absent.
Checks: `flutter test test/features/paywall` green; `npm test` in `functions/` green.

## Task 14. Server content rule (AC-8)

Traceability: X-10.

`firestore.rules`: deny all reads of `examTracks/{trackId}/proContent/{contentId}` until tiered
server content exists (W6 removes `getProContent`). Test: a Pro user's read is denied.
Checks: `npm test` in `functions/` green.

## Task 15. Deploy steps (each with Aedwon's approval)

Traceability: AC-3 deploy checks.

In order, after review: (1) W6's export and comparison of the live console rules; (2) an inventory
of custom claims confirming no user holds `pro`; (3) deploy functions; (4) set the RevenueCat
webhook URL to the deployed `revenuecatWebhook` and send a RevenueCat test event, checked end to
end; (5) the one-time reconciliation for every production customer with an active purchase, pass
or promotional entitlement, with the count reported; (6) deploy rules. Before release: the lead
lists existing promotional `pro` grants in RevenueCat production and Aedwon reissues them as
tier-named. Checks: each step's output recorded in `evidence/W3.md`.

## Task 16. Full checks, audit, review, integration

All required checks plus `npm test` in `functions/`; evidence in `evidence/W3.md`; GPT-6 Astra
audit; the Opus lead's independent review and acceptance; lead integrates. Report to Aedwon: the external setup checklist status (P1 to P4).
