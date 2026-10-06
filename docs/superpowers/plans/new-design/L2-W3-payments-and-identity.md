# L2 W3: payments and identity

Level 2 workstream plan. Date: October 6, 2026. Author: lead. Policy revision: origin/main 4478a462.
Parent: strategy B2 (W3 amended Oct 6 to add tier pricing), B4. Depends on: W0.
Spec: amendment spec (approved Oct 5); tier pricing spec `docs/superpowers/specs/2026-10-06-tier-pricing-design.md`
(required by `docs/pricing.md` before any product is created; approved by Aedwon Oct 6); `docs/pricing.md` (approved Oct 4); giveaways log
`docs/superpowers/decisions/2026-10-04-giveaways-and-gift-codes-log.md`.
Traceability rows: every row with workstream `W3`, plus S0-35 states and the trial-ending trigger.

## 1. Purpose and scope

Make who has Pro, for which exams, and until when, correct and testable, and give each signed-in
account a short ID that is safe to post publicly.

In scope:
1. **Cancellation keeps Pro until expiry** (balanced, decided Oct 4): on any cancel, expiry,
   billing or transfer event, the webhook asks RevenueCat whether the user still has active Pro
   and sets the claim from that answer. If RevenueCat cannot be reached, return an error so
   RevenueCat retries. Covers out-of-order events and the giveaway grant overlap.
   Note: at 1f79d880 the webhook's revoke set is `EXPIRATION` and `TRANSFER_OUTGOING` only. The
   level 3 plan first reproduces where Pro is cleared early on this branch (webhook, client cache,
   or claim refresh) and fixes the cause there.
2. **Short public ID** (hardened, decided Oct 4), every requirement in the giveaways log: random
   9-digit number with a check digit, server-created once per Google or Apple account, none for
   anonymous accounts, server-held mapping clients cannot read, each user reads only their own ID,
   admin-only lookup with an audit log, never a credential or URL parameter, retired on deletion and
   never reissued, covered by privacy policy, export and deletion.
3. **Pro by exam tier** (added Oct 6): tiers Student, Civil Service, Licensure, plus Season Passes,
   per `docs/pricing.md`; higher subscription tiers include lower ones; a pass covers only its own
   exam; the 7-day trial only on Monthly; upgrade on switching to a pricier exam; a lapsed plan gets
   no second trial.
4. **Entitlement states for the Pro page** (S0-35): trial running, canceled but active until a date,
   giveaway grant, unknown plan, billing problem, store errors.
5. **Trial-ending notification trigger** (S0-25): schedule and cancel the local notification 24
   hours before the first Monthly trial charge. The notification itself is W4f's reminder service.

Out of scope: Pro page screens (W4f), the exam switching screens (W4f), gift and redemption codes
(deferred to after launch), Licensure, academy and PSHS-NCE sales (Coming soon; nothing sold).

## 2. Inputs

`docs/pricing.md`; DECISIONS "Settings" (prices, Season Pass rules, Pantas ID, exam switching and
paying, Paywalls), "Free and Pro", "Last gaps" (payment pending, subscribing offline); giveaways log;
boards ST_Pro*, ST_Pass*, ST_SwitchUpgrade, ST_SwitchPassWarn, ST_AccountID*, ST_Restore*,
L_Purchase, L_RestorePurchase; traceability G-f-12 to G-f-19, G-f-22, G-f-31, G-h-5, S0-35, S0-25.

## 3. Contracts owned

| Contract | Interface |
|---|---|
| Exam tier | `PriceTier { student, civilService, licensure, nce }` and `tierForExam(examId)` from the W0 exam catalog. Mapping per pricing.md: CETs, DOST, SM to student; academy exams to student (plus a pass); CSE Professional and Subprofessional, NAPOLCOM, AFPSAT to civilService; LET, PNLE to licensure; PSHS-NCE to nce. |
| Products | Subscription ids: existing `pantas_pro_weekly`, `pantas_pro_monthly`, `pantas_pro_yearly` (student); new `pantas_cs_weekly`, `pantas_cs_monthly`, `pantas_cs_yearly`, `pantas_pass_civil_service` (tier spec, approved Oct 6), created by Aedwon before W3 integration. Passes are one-time consumable products (tier spec B3), bought again for each sitting. Ids live in one table; no screen hard-codes an id. |
| Entitlement | `Entitlement` gains `tier` (highest subscription tier held), `passes` (set of exam ids with an active pass and each end date), `state` (`free`, `trial`, `active`, `canceledActive`, `billingIssue`, `grant`, `unknown`, `paused`; `paused` added Oct 6 for AC-1; `unknown` applies only when nothing known is active; otherwise the state follows the known coverage and the unknown item is only logged, AC-7), `endsAt`, `renewsAt`, `chargesAt` (trial). `coversExam(examId)` is the single question every Pro gate asks. Callers keep `proIsActive`: the 113 references (two definitions: `entitlement.dart:48`, `revenuecat_sdk.dart:48`) keep their names; W3 makes the provider-level value equal `coversExam(activeExam)` by injecting the active exam where entitlement is read (N-23), and level 3 lists each definition's change. `mockLimit(examId)`: unlimited when covered, else one mock per 14 days per exam with `nextMockOpensAt`. |
| Pass ledger (amended Oct 6, abuse review 1) | Server-owned `users/{uid}/passes/{transactionId}` records, one per verified store transaction: `examId`, product, sitting, `endsAt`, state (`active`, `revoked`); the app's `passes` (exam id to end date) is derived from the active records (gate L2A-8). Written only by server functions (the webhook and the reconciliation job); clients read their own and never write. A product may grant only the exams the product table allows (`pantas_pass_civil_service`: CSE Professional and CSE Subprofessional); any other exam id is rejected. Refunds and revocations set `revoked`; transfers move the record; duplicate deliveries are no-ops. A pass for an exam with no future published sitting grants nothing and is logged for Aedwon. |
| Season Pass end | A pass ends on the exam's published date (last day for multi-day exams). If the date moves later, the pass moves with it; if earlier, it keeps the later date. No published date means the pass cannot be bought. Exam dates come from the W0 exam catalog's `publishedSittings`, never the student's own date or an inferred date. |
| Switching rule | `switchOutcome(from, to, entitlement)`: `keepsPro`, `upgradeOffer(tierPlans)` (no trial, with "Switch on Free"), `passWarning` (pass stays with its exam), `free`. W4f renders it. Paywalls never appear after onboarding or for Free students switching. |
| Purchase operations | `purchase(product)`, `restore()`, `manage()` return typed results: `success`, `pending` (payment pending, nothing can be bought twice), `offline`, `cancelled`, `storeError`, `notConfirmedYet`. Copy belongs to W4f. |
| Public ID | Firestore document readable only by its owner holding the 9-digit ID; Cloud Function `ensurePublicId` (server-only creation on first Google or Apple sign-in); admin-only lookup path with audit log; check-digit validator shared by app and functions. App reads `publicIdProvider` (states: `notSignedIn`, `notReady`, `ready(digits)`). Display grouping is W4f's (threes for 9 digits). |
| Trial-ending trigger | W3 owns the interface `TrialEndingNotifier` in `lib/features/paywall/application/trial_ending_notifier.dart` with `Future<void> schedule(DateTime chargeAt, String priceText)` and `Future<void> cancel()`, and `TrialEndingScheduler.sync(entitlement)`, which calls it; it replaces the no-op `TrialReminderScheduler`. W3 lands with a no-op binding; W4f's `ReminderService` implements `TrialEndingNotifier` and binds it. |
| State split | W3 owns the entitlement states for S0-35 and G-f-12 to G-f-19 (logic); W4f owns their screens and copy. |

Contracts consumed: W0 data layer (app schema 25, content schema 10) and the W0 exam catalog,
including `functions/src/examCatalog.json` for pass end dates; a new local table needs a W0
amendment first.

## 4. Behavior

- Free sees every screen and row; Pro shows only when a Pro button is tapped (DECISIONS "Free and Pro").
- Nothing a student made is paywalled. Mock review gating (R-12) uses `coversExam`.
- Offline: the last known entitlement stands until the paid period ends, then for 3 more days with
  no successful check; then Pro features pause (§10, AC-1). Purchases and restores need a connection.
- Placeholders: none. Prices come from the store, never typed in code; the table in pricing.md is the
  check.
- External setup Aedwon performs (instructions in level 3, done before W3 integration): create the
  Civil Service Weekly (₱49), Monthly (₱149, 7-day trial), Yearly (₱1,199) and pass (₱499) products
  in Play Console;
  move the Student trial offer from Yearly to Monthly; mirror both in RevenueCat entitlements and
  offerings.

## 5. Motion

None owned. Loading on purchase and restore follows L_Purchase and L_RestorePurchase (W2 loading
tiers).

## 6. Acceptance

- Abuse case tests (§10): one or more per AC item, named after it.
- Unit tests for tier mapping, `coversExam` (tier inclusion, pass scope, pass end dates and moves),
  `switchOutcome` for every case on the switching boards, trial eligibility (Monthly only, none after
  a lapse).
- Functions tests: webhook sets the claim from RevenueCat's answer for every event type, retries on
  RevenueCat failure, handles out-of-order events; public ID rules tests (owner-only read, no client
  write), uniqueness under concurrent creation, check digit, anonymous accounts get none, deletion
  retires the ID.
- GPT-6 Astra audit, then the Opus lead's independent review and acceptance (B7 as amended) before integration.
- Full required checks.
- Aedwon: a real test purchase and restore on Play's test track for Student and Civil Service after
  his console setup (part of W5's A03).

## 7. Risks and stop conditions

- Payments, entitlement and student data: every finding goes to the lead (SUBAGENTS 7b).
- Product ids or store prices not yet created: stop that task and report; do not invent ids.
- Any change to Firestore rules or deployed functions is deployed only with Aedwon's approval.
- If the webhook fix needs a RevenueCat secret API key that is not configured, stop and report.
- Store price points at launch (₱49, ₱149, ₱1,199, ₱499) must be confirmed available in the
  Philippines before products are created (pricing.md "Not yet settled"); if one is not, stop and ask.
- Level 3 states how stored pass end dates are updated when a catalog date moves later (a new
  export, a functions deploy with Aedwon's approval, and a recompute of affected passes; gate N3-8).
- An exam with no published sitting: its pass cannot be bought (D-227); never infer a date.

## 8. Files and directories

`lib/features/paywall/` (domain, data, application; not presentation), `lib/core/entitlement/`
(currently empty; only if providers move), `functions/src/revenuecat*.ts`, new
`functions/src/publicId*.ts`, `firestore.rules`, tests under `test/features/paywall/` and
`functions/test/`. Amended Oct 6 (level 3 gate review 1) (L3-7), cross-family edits named in the level 3 plan: `lib/app/router.dart` (after W1
integrates), `lib/features/settings/presentation/pages/pro_page.dart` and
`lib/features/paywall/presentation/subscription_panel.dart` (exhaustive switches only),
`lib/features/legal/domain/legal_document.dart` (privacy sentences after Aedwon approves them),
`functions/src/deleteAccount.ts`, `recordSignInEvent.ts` (after W6's limit), `functions/src/index.ts`
(exports only, after W6 Task 1), `exportData.ts` is no longer
edited (W6 disables it; the public ID goes into the manual DPO export); `lib/core/sync/local_state_wiper.dart`,
`lib/core/auth/auth_repository.dart`, `lib/core/sync/eligibility/sync_claim_gateway.dart` (AC-3, AC-5)
(`functions/package.json` moved to W6, Oct 6),
`lib/core/auth/public_id_provider.dart`, `lib/features/mock_exam/domain/mock_availability.dart`,
`lib/features/roadmap/domain/roadmap_inputs.dart`, `roadmap_inputs_reader.dart`, `mock_day.dart`,
`mock_availability_provider.dart` (the Pro flag source), `lib/app/bootstrap.dart` (mock entitlement
override), and after W1's split the builders in `lib/app/routes/quiz_routes.dart`, `mock_routes.dart`
and `settings_routes.dart` (amended at level 3 gate review 2). Each W4 family switches its own gates to `proForActiveExamProvider`; plan status (Settings Pro
row, Pro page plan name, Your plan rows and Manage; amended at level 3 gate review 4) keeps the any-plan flag, and the Pro page's offer-or-owned
choice reads the new provider.

## 9. Order and parallelism

After W0, in parallel with W1 and W6. W3's functions tasks start after W6 Task 1 integrates (its
package and test runner). Deploy policy (gate L2A-14): each workstream's backend changes deploy
after that workstream's review, with Aedwon's approval, once W6 Task 1 has landed. `firestore.rules` edits: W6 (user record create rule) before W3, then W3, then
W4g. W4f consumes W3's contracts. Executor and review per strategy B7 as amended October 6: GPT-6.1
Sol High builds, GPT-6 Astra audits, and the Opus lead reviews and accepts every money and
entitlement change before integration.

## 10. Abuse cases (added October 6, abuse review 1)

Source: `gates/abuse-review-1.md` (findings CX-n). Each case is a requirement with a test.

| ID | Finding | Abuse case | Required behavior |
|---|---|---|---|
| AC-1 | CX-2 | Block RevenueCat traffic after a purchase or trial, or move the clock, to keep Pro forever | Cached Pro holds until the paid period ends (`expiresAt` of the subscription, pass or grant), then 3 more days with no successful check (Aedwon, Oct 6); then the entitlement state is `paused` and Pro gates are closed until one successful check. Time rules (gate L2A-1, L2A-3, L2A-26): the app keeps a high-water mark of every time it has seen (device clock and trusted times such as RevenueCat `requestDate`); effective time is never earlier than the mark (it is the later of the device clock and the mark). Every backward step of the device clock since the last successful check adds to one running total; once the total passes 10 minutes the offline window counts as used and Pro pauses until a successful check (gate L2A2-1; one ordinary time-sync correction of a minute or two does not pause). A successful check means a RevenueCat answer whose entitlement verification result is `verified` (not `verifiedOnDevice`, `notRequested` or failed) and whose `requestDate` is strictly later than the last trusted time stored. The SDK's cache keeps its old `requestDate` and a replayed response fails verification, so neither counts; the stored trusted time never moves backward (gates L2A3-1, L2A4-1). The stored trusted time and the mark belong to the device and survive sign-out and account switch; AC-5 clears only the cached entitlement (L2A4-6). Whenever Pro is paused, or a backward step was counted, and the phone is online, the app calls `invalidateCustomerInfoCache()` before `getCustomerInfo()`, so it gets a fresh server answer instead of the SDK's cache, and an honest user whose clock was wrong is unpaused at once (gate L2A5-1). Cached Pro in this AC always means the app's own last confirmed entitlement (`entitlement_snapshot_store.dart`), never the SDK's cache, so a failed forced fetch changes nothing (L2A6-4). Clock changes while the app is closed (gate L2A5-4): at every start the app stores the boot's wall time (device clock minus `SystemClock.elapsedRealtime()`, which counts deep sleep) and that elapsed time; on the next start in the same boot, a boot wall time earlier than the stored one by more than 2 seconds counts as a backward step of that size; a new boot is an elapsed time lower than the stored one. One setback is counted once, by whichever detector sees it first (L2A6-2, L2A6-3). Only a clock change followed by a reboot stays unseen. A successful check resets the mark to that trusted time and clears the total, so an honest user whose clock was once wrong is not locked out (L2A2-2). Effective time is the latest of: the device clock, the mark, and the last trusted time plus the elapsed time since it while the phone has not restarted (L2A3-10). A verified RevenueCat answer is judged by its own `requestDate`, never the device clock; a verified inactive answer revokes only when its `requestDate` is newer than the active evidence held (L2A2-10). Inside the window a failed refresh stays silent. Paused copy, approved by Aedwon Oct 6: "Connect once to keep using Pro." (W4f on the Pro page; every family's Pro gate through W2's `ProPausedLine`). Nothing the student made is locked. Residual risks for Aedwon's acceptance at E14 (gates L2A-4, L2A4-2): refund then stay offline keeps Pro until the old paid-period end plus 3 days (Yearly: up to a year; pass: until its sitting); and, with RevenueCat blocked and automatic time off, setting the clock back and then rebooting before every session spreads the paid period plus 3 days of in-app time over a longer calendar span (a phone cannot see a clock change across a reboot without asking a server). Lead recommendation: accept both. The clock case needs a clock change and a reboot before every session; closing it fully would need a server check before each session, which the offline rule forbids. Tests (L2A4-10, L2A6-1): a cached answer does not reset the mark; a `verifiedOnDevice` answer does not count; repeated small setbacks pause Pro; a clock moved back during a session counts; the clock was a year ahead when RevenueCat cached an answer, is corrected, and with the network up the next check invalidates the cache and unpauses Pro; a clock set back while the app is closed in the same boot counts once; a reboot followed by an ordinary start does not pause Pro; with RevenueCat down after the cache is cleared, Pro inside the window comes from the app's own last confirmed entitlement. |
| AC-2 | CX-6 | A signed but wrong event (sandbox, other app, unknown product) grants production Pro | The webhook acts only on events for the Pantas app id, and the claim is computed from the reconciled RevenueCat answer (AC-3) after filtering it the same way: production purchases of products in the product table with entitlement `pro`. Sandbox purchases count only in pantas-staging, and in pantas-prod only for named Pantas uids on a server-only tester allowlist that Aedwon maintains, with each such grant logged (gates L2A-6, L2A2-7). Promotional grants are accepted only as RevenueCat promotional entitlements and follow AC-7. |
| AC-3 | CX-5, CX-16 | A late or replayed event turns expired Pro back on; concurrent events race; a stale claim never ends | Every event type triggers reconciliation (for example `INITIAL_PURCHASE`, `RENEWAL`, `PRODUCT_CHANGE`, `UNCANCELLATION`, `NON_RENEWING_PURCHASE`, `CANCELLATION`, `EXPIRATION`, `BILLING_ISSUE`, `TRANSFER`, `SUBSCRIPTION_EXTENDED`, `REFUND_REVERSED`; L2A2-9) and is answered by reading RevenueCat's current state with the P1 read-only key. The signed request is refused if its timestamp is older than 5 minutes; level 3 confirms how RevenueCat signs retries and widens the limit if retries keep the original time (L2A2-8). The answer time (the function's own server time taken just before the RevenueCat read, since API v2 returns no request time; amended at level 3) is stored with the claim; inside a Firestore transaction per user, a write older than the stored one is refused, and event ids are deduplicated in the same transaction. The claim carries `proUntil` as a number of milliseconds: the latest end among the user's active subscription periods, active passes (from the pass ledger) and promotional grants, plus a 1-day margin so a renewal that RevenueCat reports after the period ends does not cut sync (accepted: up to 1 extra day of server Pro after a plan ends without a final event; a refund or revocation removes the claim at once, L2A3-11). Rules compare it as `request.auth.token.proUntil > request.time.toMillis()`. After a claim change the server sets `claimsChangedAt` on `users/{uid}` (readable by its owner without Pro); the app refreshes its ID token when that changes, after every purchase and restore, and once after a permission-denied sync (L2A2-3). No migration is needed: no functions have ever been deployed (checked Oct 6: the Cloud Functions API is off in all three projects), so no live user holds a `pro` claim. Deploy steps, each with Aedwon's approval (gate L2A3-3): before W3's first rules deploy, an inventory of custom claims confirms no user holds `pro`; right after W3's functions deploy, the RevenueCat webhook URL is set to the deployed function, a RevenueCat test event is checked end to end, and a one-time reconciliation (the webhook's own code path) runs for every RevenueCat production customer with an active purchase, pass or promotional entitlement, with the count reported, so anyone who bought before the webhook went live gets their claim (gate L2A4-4). W5 re-checks the webhook URL and that claims match RevenueCat on the final build. |
| AC-4 | CX-3, CX-4 | A modified app buys the ₱499 pass for a pricier exam; a refunded pass keeps working; a duplicate delivery doubles a pass | The pass ledger contract (§3). The exam id is bound to the verified transaction; level 3 confirms the RevenueCat mechanism. If no reliable binding exists, stop and ask Aedwon (alternative: one pass product per exam, which needs new permanent product ids). A modified app can still choose CSE Professional or Subprofessional for the same product; both are allowed and priced the same, so this is acceptable. Refund signal (gate L2A-9): level 3 names the RevenueCat event or REST field that reports a refunded non-subscription purchase and tests it; if RevenueCat reports none for consumables, stop and ask (fallback: a daily reconciliation against RevenueCat's purchase list). |
| AC-5 | CX-8 | A second account on a shared phone keeps the first account's Pro after sign-out | Sign-out, account switch and deletion clear the cached entitlement and in-memory state and switch the RevenueCat identity before anything reads Pro. Purchases wait until the new identity is set. Restore behavior (gate L2A-20): RevenueCat's project setting stays "Transfer to new App User ID" (the default); a restore on a second Pantas account moves Pro there and the first account loses it (handled as `TRANSFER`, AC-3); recorded and tested. |
| AC-6 | CX-9 | A rooted phone feeds the RevenueCat SDK a forged "active" response | Turn on RevenueCat trusted entitlements; a result whose verification failed never grants Pro. Cached data from before follows AC-1. |
| AC-7 | CX-11 | A giveaway grant overgrants a tier, or cannot be read as any tier | Coverage is the same rule on the phone and on the server (gate L2A4-3; tests: an old or refunded pass in RevenueCat's purchase list with no active ledger record covers nothing, L2A6-1): the union over active subscriptions of known products (all RevenueCat reports, not only the one product named on the `pro` entitlement), active passes from the pass ledger only, and active `promo_*` entitlements. A non-subscription purchase in RevenueCat's lists never grants coverage by itself; on the phone, passes come from the user's own ledger records (gate L2A5-3). A product or entitlement not in the table adds nothing and removes nothing, and is logged; so a promotional grant of `pro` itself covers no exam unless a known product also does. Before W3 ships, the lead lists existing promotional `pro` grants in RevenueCat production and Aedwon reissues them as tier-named grants; the setup steps tell Aedwon to grant giveaways only with the two entitlements below, and new products enter the product table before they go on sale (gate L2A3-2). Giveaways use tier-named RevenueCat promotional entitlements: `promo_student` and `promo_civil_service` (Aedwon, Oct 6: every giveaway names its tier; Civil Service includes Student; no default tier). The product table maps each to its tier; a promotional entitlement the table does not know grants nothing and is logged. A later tier (for example Licensure) adds one entitlement and one table row when its content ships (deferred, Aedwon Oct 6). No admin callable is needed for grants. |
| AC-8 | CX-10 | A Student subscriber reads Civil Service server content | Rules deny `examTracks/{trackId}/proContent` reads until tiered server content exists; when it does, the rule checks tier coverage and pass scope. |
| AC-9 | CX-19 | Repeat free trials | Google Play's rule (Aedwon, Oct 6): one trial per Google account that never had a Pantas subscription; the app shows the trial only when RevenueCat reports the offer eligible. New Google accounts are an accepted risk. |
| AC-10 | review section 4 | A patched app unlocks local Pro features | Accepted risk (Aedwon accepts at E14). Server features (sync, server content) check the claim, never the app. |
| AC-11 | review section 4 | Restore on another account shares one purchase | AC-5's restore behavior; one account holds Pro at a time. |

