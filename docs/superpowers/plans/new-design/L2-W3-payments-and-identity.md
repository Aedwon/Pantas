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
| Products | Subscription ids: existing `pantas_pro_weekly`, `pantas_pro_monthly`, `pantas_pro_yearly` (student); new `pantas_cs_weekly`, `pantas_cs_monthly`, `pantas_cs_yearly`, `pantas_pass_civil_service` (tier spec, approved Oct 6), created by Aedwon before W3 integration. Passes are non-renewing products. Ids live in one table; no screen hard-codes an id. |
| Entitlement | `Entitlement` gains `tier` (highest subscription tier held), `passes` (set of exam ids with an active pass and each end date), `state` (`free`, `trial`, `active`, `canceledActive`, `billingIssue`, `grant`, `unknown`), `endsAt`, `renewsAt`, `chargesAt` (trial). `coversExam(examId)` is the single question every Pro gate asks. Callers keep `proIsActive`: the 113 references (two definitions: `entitlement.dart:48`, `revenuecat_sdk.dart:48`) keep their names; W3 makes the provider-level value equal `coversExam(activeExam)` by injecting the active exam where entitlement is read (N-23), and level 3 lists each definition's change. `mockLimit(examId)`: unlimited when covered, else one mock per 14 days per exam with `nextMockOpensAt`. |
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
- Offline: the last known entitlement stands; purchases and restores need a connection.
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
`functions/test/`.

## 9. Order and parallelism

After W0, in parallel with W1. W4f consumes its contracts. Opus implements and reviews (B7).
