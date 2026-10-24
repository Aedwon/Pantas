# C3 web purchase gateway: task plan

Date: October 24, 2026. Lead: Claude (Opus 5.5). Implementor: Sonnet 5.5, high effort.
Complexity: minimal (Aedwon chose "Minimal (Recommended)" on October 24, 2026).
Controlling records: plan `docs/superpowers/plans/2026-10-19-pwa-launch.md` (C3, C6, A6),
ruling `docs/superpowers/plans/pwa-launch/C1-C10-ruling.md` (C1 items 2 and 6), server contract
`functions/PAYMONGO.md` and `functions/src/paymongoCheckout.ts`, `functions/src/webTrial.ts` on
this branch. Policy: `AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md` from origin/main.

## Goal

The client half of web payments. On web, the Pro page (W4f Task 6, Codex lane A6, not started)
must be able to: list the web plans, start a PayMongo checkout, handle the return to
`/pro?checkout=success|cancelled`, start the once-per-account web trial, and see Pro access once
the server grant exists. Mobile keeps RevenueCat unchanged.

## Minimal scope (what "minimal" means here)

In:
1. A web gateway that implements the existing `RevenueCatPassGateway` interface, so the existing
   paywall controller and Pro page code paths work on web with the fewest changes for W4f.
   - `currentOffering`: the web plans (`pantas_cs_weekly`, `pantas_cs_monthly`,
     `pantas_cs_yearly`, and the CSE passes) with prices from the client's existing price source.
     If the client has no price source that matches `docs/pricing.md`, stop and report. Never
     invent or hard-code a price that is not traceable to `docs/pricing.md`.
   - `purchase` and `purchasePass`: call the `createPaymongoCheckout` callable (region
     `asia-southeast1`) with `{product}`, then open `checkoutUrl` in the same tab with the
     existing `url_launcher`. Map callable errors (`invalid-argument`, `resource-exhausted`,
     `failed-precondition`, `already-exists`, `unauthenticated`) to the existing
     `PaymentOperationResult` kinds.
   - `restorePurchases`: refresh the ID token with the existing `refreshPaymentClaimToken`,
     re-read the grant ledger, emit the updated entitlement.
   - Entitlement: read owner-readable `users/{uid}/grants` (state `active`, `endsAt` after now)
     and map them into the existing `Entitlement` fields (subscription grants and trial grants as
     `CoveragePeriod`s, pass grants into `passes`). Ruling C1 item 2 allows mapping instead of a
     model change. Do not change the `Entitlement` model unless mapping is impossible; if so, stop.
   - `configure`, `logIn`, `logOut`, `clearIdentity`: no RevenueCat; keep the uid for ledger reads.
2. A return handler the Pro page can call with the current URI: on `checkout=success`, run the
   restore path (token refresh plus ledger read) and report whether Pro is now active. The
   webhook may lag, so one refresh that finds no grant returns a "pending" result, not a failure.
   On `checkout=cancelled`, change nothing. No polling loop (that is balanced scope).
3. A thin web trial call: `startWebTrial` callable, then the restore path. Map
   `failed-precondition` to a "trial not available" result.
4. Provider wiring: on web (`kIsWeb`) the payment gateway provider builds the web gateway; mobile
   construction is unchanged. If the web platform seam from `web/pwa-foundation-r1` is needed and
   absent on this branch, use `kIsWeb` at the existing provider and say so in the report.

Out (do not build): router or Pro page edits (W4f Task 6 owns them), any visible UI or copy,
polling or retry, duplicate-return protection beyond what the server already does, server
changes, new dependencies, PayMongo live or test calls.

## Files

Expected (adjust names to the codebase's conventions, report any extra file):
- New: `lib/features/paywall/data/web_payment_gateway.dart` (gateway, grant mapping, return
  handler, trial call). Split the grant-to-entitlement mapping into its own file only if it is
  large.
- Modify: the provider that constructs the payment gateway (find it from
  `lib/features/paywall/application/`), and the `PaymentOperationResult` kinds only if an
  existing kind cannot express "pending" or "trial not available".
- Tests: `test/features/paywall/data/web_payment_gateway_test.dart` with fakes for the callable,
  the ledger reader, the URL opener and the token refresher (use `mocktail`, already a dev
  dependency; inject seams through the constructor rather than adding a fake Firestore package).

Do not touch files owned by W4a, W4b or W4f work in progress. `lib/app/router.dart` is out of scope.

## Steps (test first, one at a time)

1. Grant mapping: tests for active subscription grant, trial grant, pass grant, revoked grant,
   expired grant, two stacked grants. Then the mapping.
2. Checkout: tests that `purchase` calls the callable with the product id and opens the URL; each
   callable error maps to the right result. Then the code.
3. Return handler and restore: success with grant found, success with no grant yet (pending),
   cancelled (no calls). Then the code.
4. Trial: success, already used. Then the code.
5. Provider wiring and the offering. Test that web builds the web gateway (or document why the
   test cannot express `kIsWeb` and test the factory function instead).

## Verification (paste actual output)

- `flutter test test/features/paywall` and then full `flutter test`
- `flutter analyze`
- `dart format --output=none --set-exit-if-changed lib test`
- `dart run tool/check_layering.dart`
- `dart run tool/check_no_ai_attribution.dart`
- `flutter build web --release -t lib/main_staging.dart` only if this branch has a web entry
  that builds; otherwise say it was not run and why.

Not verifiable here: a real PayMongo checkout and webhook (C5 needs Aedwon's test keys and a
staging deploy). Report that as unverified.

## Stop conditions

Any `SUBAGENTS.md` Part 6 condition, plus: no traceable price source; the `Entitlement` model
cannot represent grants without a model change; the callable contract on this branch differs from
this plan; a needed file is owned by in-flight W4a/W4b/W4f work.
