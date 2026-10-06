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
| Entitlement | `Entitlement` gains `tier` (highest subscription tier held), `passes` (set of exam ids with an active pass and each end date), `state` (`free`, `trial`, `active`, `canceledActive`, `billingIssue`, `grant`, `unknown`), `endsAt`, `renewsAt`, `chargesAt` (trial). `coversExam(examId)` is the single question every Pro gate asks. Callers keep `proIsActive`: the 113 references (two definitions: `entitlement.dart:48`, `revenuecat_sdk.dart:48`) keep their names; W3 makes the provider-level value equal `coversExam(activeExam)` by injecting the active exam where entitlement is read (N-23), and level 3 lists each definition's change. `mockLimit(examId)`: unlimited when covered, else one mock per 14 days per exam with `nextMockOpensAt`. |
| Pass ledger (amended Oct 6, abuse review 1) | Server-owned `users/{uid}/passes/{examId}` records, one per verified store transaction (keyed by transaction id): product, exam, sitting, `endsAt`, state (`active`, `revoked`). Written only by the webhook; clients read their own and never write. A product may grant only the exams the product table allows (`pantas_pass_civil_service`: CSE Professional and CSE Subprofessional); any other exam id is rejected. Refunds and revocations set `revoked`; transfers move the record; duplicate deliveries are no-ops. A pass for an exam with no future published sitting grants nothing and is logged for Aedwon. |
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
- Independent Opus code review (B7) before integration.
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
`functions/src/deleteAccount.ts`, `recordSignInEvent.ts`, `exportData.ts` (`functions/package.json` moved
to W6, Oct 6),
`lib/core/auth/public_id_provider.dart`, `lib/features/mock_exam/domain/mock_availability.dart`,
`lib/features/roadmap/domain/roadmap_inputs.dart`, `roadmap_inputs_reader.dart`, `mock_day.dart`,
`mock_availability_provider.dart` (the Pro flag source), `lib/app/bootstrap.dart` (mock entitlement
override), and after W1's split the builders in `lib/app/routes/quiz_routes.dart`, `mock_routes.dart`
and `settings_routes.dart` (amended at level 3 gate review 2). Each W4 family switches its own gates to `proForActiveExamProvider`; plan status (Settings Pro
row, Pro page plan name, Your plan rows and Manage; amended at level 3 gate review 4) keeps the any-plan flag, and the Pro page's offer-or-owned
choice reads the new provider.

## 9. Order and parallelism

After W0, in parallel with W1 and W6. Any functions or rules deploy waits for W6's deployable
package (W6 Task 1). `firestore.rules` edits: W6 (user record create rule) before W3, then W3, then
W4g. W4f consumes W3's contracts. Opus implements and reviews (B7).

## 10. Abuse cases (added October 6, abuse review 1)

Source: `gates/abuse-review-1.md` (findings CX-n). Each case is a requirement with a test.

| ID | Finding | Abuse case | Required behavior |
|---|---|---|---|
| AC-1 | CX-2 | Block RevenueCat traffic after a purchase or trial, or move the clock, to keep Pro forever | Cached Pro holds until the paid period ends (`expiresAt` of the subscription, pass or grant), then 3 more days with no successful check (Aedwon, Oct 6); then Pro gates pause until one successful check. The app stores the latest trusted time it has seen (RevenueCat `requestDate` or server time) and treats a device clock earlier than it as that time. Inside the window a failed refresh stays silent. Paused copy, for Aedwon's approval: "Connect once to keep using Pro." (W4f shows it on the Pro page and at a paused gate). Nothing the student made is locked. |
| AC-2 | CX-6 | A signed but wrong event (sandbox, other app, unknown product) grants production Pro | The webhook keeps app id, environment, product id, entitlement ids and expiry from each event and acts only when they match: production events in pantas-prod, sandbox in staging, a product in the product table, entitlement `pro`. Promotional grants are accepted only as RevenueCat promotional entitlements and are recorded (AC-7). |
| AC-3 | CX-5, CX-16 | A late or replayed event turns expired Pro back on; concurrent events race | Every entitlement-changing event (grants included) is answered by reading RevenueCat's current state (P1 read-only key), not by the event type. Per-user updates run in a Firestore transaction with event-id deduplication. Events older than the last applied one are ignored. The claim carries `proUntil` (the current paid period end from RevenueCat) and the sync rules require `pro == true && proUntil > request.time`, so a stale claim ends on its own. |
| AC-4 | CX-3, CX-4 | A modified app buys the ₱499 pass for a pricier exam; a refunded pass keeps working; a duplicate delivery doubles a pass | The pass ledger contract (§3). The exam id must be bound to the verified transaction; level 3 confirms the RevenueCat mechanism. If no reliable binding exists, stop and ask Aedwon (alternative: one pass product per exam, which needs new permanent product ids). |
| AC-5 | CX-8 | A second account on a shared phone keeps the first account's Pro after sign-out | Sign-out, account switch and deletion clear the cached entitlement and in-memory state and switch the RevenueCat identity before anything reads Pro. Purchases wait until the new identity is set. |
| AC-6 | CX-9 | A rooted phone feeds the RevenueCat SDK a forged "active" response | Turn on RevenueCat trusted entitlements; a result whose verification failed never grants Pro. Cached data from before follows AC-1. |
| AC-7 | CX-11 | A giveaway grant overgrants a tier, or cannot be read as any tier | Each grant has a server record (tier, end date, public ID, giveaway) written by the admin path. A RevenueCat promotional grant with no record counts as Student tier until its end date, never higher. |
| AC-8 | CX-10 | A Student subscriber reads Civil Service server content | Rules deny `examTracks/{trackId}/proContent` reads until tiered server content exists; when it does, the rule checks tier coverage and pass scope. |
| AC-9 | CX-19 | Repeat free trials | Google Play's rule (Aedwon, Oct 6): one trial per Google account that never had a Pantas subscription; the app shows the trial only when RevenueCat reports the offer eligible. New Google accounts are an accepted risk. |
| AC-10 | review section 4 | A patched app unlocks local Pro features | Accepted risk (Aedwon accepts at E14). Server features (sync, server content) check the claim, never the app. |

