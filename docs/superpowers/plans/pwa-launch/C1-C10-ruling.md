# C1 and C10 lead ruling: PayMongo entitlement path and server-side roadmap

Date: October 19, 2026. Lead: Claude (Opus 5.5). Plan: `docs/superpowers/plans/2026-10-19-pwa-launch.md`.
Code read (via Haiku 5.5 crawls, lead-reviewed): `origin/integration/new-design-r1` at 5e6cda45.
Facts: `evidence/C1-entitlement-facts.md`, `evidence/C10-roadmap-portability.md`.
PayMongo API details (Checkout Sessions, the paid-checkout webhook event, the signature header)
are to be verified against PayMongo's current documentation in C2 and C4, not taken from this file.

## C1. One entitlement record, one more source

W3 already has the right shape: every grant source ends in `users/{uid}/server/entitlement`
(`pro`, `proUntil`, `facts`, `version`, `claimsVersion`), coverage is computed in
`revenuecatCoverage.ts` `coverageAt`, and `copyEntitlementClaims` copies `pro` and `proUntil` (latest
end plus 24 hours) to Auth claims, with the hourly repair and daily check jobs. Firestore rules
already gate on the claims (`hasLivePro`). PayMongo and the web trial plug into this; nothing
parallel is built.

1. **Grant ledger.** New server-only collection `users/{uid}/grants/{grantId}`, modeled on the
   pass ledger: `source` (`paymongo` | `trial`), `product` (product id from `functions/src/products.json`),
   `tier`, `startsAt`, `endsAt` (ms), `paymentId` (PayMongo id, paymongo only), `state`
   (`active` | `revoked`), `createdAt`. Rules: owner read allowed (like passes), write false.
2. **Coverage.** `coverageAt` adds live grants (state active, `endsAt` after now) beside
   subscriptions, passes and promotions. Claims, repair and check jobs then work unchanged.
   Add a `grants` list to the client `Entitlement` (or map grants to `CoveragePeriod`s) so
   `proIsActive` and `coversExam` see them; the web gateway reads the grant ledger the way the live
   gateway reads passes, and the claim refresh after payment reuses `refreshPaymentClaimToken`.
3. **Products.** Reuse `pantas_cs_weekly`, `pantas_cs_monthly`, `pantas_cs_yearly`,
   `pantas_pass_cse_pro`, `pantas_pass_cse_sub` (tier civilService). Add a per-product web
   price in ₱ and a prepaid length to `products.json`: weekly 7 days; monthly to the same date next
   month and yearly to the same date next year (Aedwon, October 19), clamped to the month's last day,
   computed in Philippine time. The pass uses W3's `sittingFor` end (end of the next published sitting, Philippine time).
   Prices come only from `docs/pricing.md`.
4. **Prepaid extension.** A paid grant starts at the later of now and the latest live `endsAt` of
   the same or a higher tier for that account, so buying early never wastes days. A pass is
   per exam and does not stack on subscriptions.
5. **Webhook.** HMAC check per PayMongo docs, then dedupe with the existing
   `webhookEvents/{eventId}/users/{uid}` pattern inside the same transaction that writes the grant
   and bumps `version`; rate limit with the existing `webhookRateLimits` pattern. The server
   re-reads the checkout session from the PayMongo API before granting, as W3 re-reads RevenueCat;
   the event body alone grants nothing. The checkout session carries `uid` and `product` in its
   metadata, set by the checkout callable, and the webhook rejects a mismatch.
6. **Trial (C6).** New server-only record `users/{uid}/server/trial` (`usedAt`, `grantId`). The
   trial callable refuses anonymous accounts, any account with a trial record, and any account with
   a paid grant, subscription or pass ever recorded. It writes a 7-day `trial` grant at tier
   civilService. Mobile trial rules (RevenueCat Monthly) stay as they are.
7. **Refunds and disputes.** PayMongo refund and dispute events set the matching grant to
   `revoked` and recompute; no partial-day math.
8. **Secrets.** `PAYMONGO_SECRET_KEY` and `PAYMONGO_WEBHOOK_SECRET` as Functions secrets per
   project; test keys on `pantas-staging` only.

## C9. Answer sync is a new ingest path, not the existing sync

Finding: the existing sync (`sync_state`, `sync_generations`) is gated by `isProOwner` in
`firestore.rules` (named Pro accounts only). It stays as it is. C9 adds a callable that accepts one
batch per finished session from any account (anonymous included), checks App Check and a
per-account limit, de-duplicates by session id, and writes server-only
`users/{uid}/server/answers/{sessionId}`. Anonymous accounts that never sign up are removed by
the existing `cleanupOrphanAnons` job; check it also deletes this subcollection.

## C10. Roadmap and insights on the server

Findings:

- The roadmap engine (`lib/features/roadmap/domain`, entry `BuildRoadmap.call(RoadmapInputs) ->
  Roadmap`, about 2,200 to 2,450 lines) imports only pure Dart packages (collection, meta,
  freezed_annotation). It can run on the server unchanged.
- Its inputs are read today by `RoadmapInputsReader` from drift through Riverpod; the server needs
  its own reader over the C9 answers and the account's exam settings.
- Pro insights: the math (`lib/features/metrics/domain`, about 600 lines) is pure. The signals
  (`lib/features/metrics/signals`, about 1,350 lines in 17 files) read drift directly. They need a
  refactor that splits each signal into a row reader and a pure function over rows. The device
  keeps using the same pure functions, so there is still one copy of the logic.

Ruling:

1. Move the pure roadmap engine, the metrics math and the refactored pure signals into a pure Dart
   package in the repository (for example `packages/pantas_core`), used by the app and the server.
2. Runtime: a Node callable stays the front door (Auth, App Check, limits, tier check), and calls
   the shared Dart code compiled to JavaScript with `dart compile js`, exported through
   `dart:js_interop`. First spike (half a day): compile `BuildRoadmap` and run it from a Node test
   with fixed inputs, and compare the output with the Dart test fixture. If the spike fails, fall
   back to a Dart service on Cloud Run behind the same callable.
3. Compute on write: when a session batch arrives (C9), recompute and store the roadmap and
   insights in `users/{uid}/server/roadmap`; the read callable returns only the tier's parts
   (Free: Today; Pro: Coming up, History, insights). One stored read per view.
4. Revised estimate for C10: roadmap on the server about 3 to 4 days; signal refactor and insights
   about 4 to 5 days. Total about 1.5 weeks, not the 1 week the plan assumed. Plan total for C7
   to C10 rises from about 2 weeks to about 2.5 weeks.

## Sequencing

- C10 step 1 (shared package plus spike) can start now; it touches roadmap and metrics domain
  files, which W4b also uses, so the integration owner orders it with W4b.
- C1 to C6 start after the web foundation (B2, B3) lands on its branch.
- C9 before C10 step 3.
