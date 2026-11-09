# PayMongo test-mode run on staging, 9 November 2026

**Run by:** Claude Opus 5.5 (lead, launched by the manager thread), branch `ops/paymongo-test-r1`.
**Policy commit:** `44576bfdb` (main). **Target:** https://staging.pantas.study, Firebase project
`pantas-staging`, PayMongo **test mode** only. No real money moved. Prod was read only.
**Why:** Aedwon asked whether PayMongo was ever tested. It was not. He queued this run:
"okay, put that in the queue first hehe" (launch log, "PayMongo readiness and the manager queue").

## Verdict

**Partial. The paid flows could not run.** Staging has no PayMongo webhook of its own. The only
test webhook on the PayMongo account points at **pantas-prod**, and prod's functions run with the
same test key. A successful staging test payment would therefore be delivered to prod and write
records into prod Firestore, which this run must not do. Steps 3, 5 and 6 wait on Aedwon (see
"What Aedwon must do").

| Step | Result |
|---|---|
| 1. Sign in on staging with a test account | **Pass** (staging-only accounts, see Method) |
| 2. Start checkout: CS Monthly and the Season Pass | **Pass** up to payment. Paying a success card or QR Ph was **blocked** (D1) |
| 3. Webhook grants the right period, Pro unlocks, return page | **Blocked** (D1). Return page checked by hand on staging: works. Live return URL is wrong (D2) |
| 4. Failed card: no access, clear message | **Pass** (PayMongo's message for a declined card; no grant). One PayMongo-side gap (D5) |
| 5. Refund revokes, partial refund shortens | **Blocked** (D1). Needs a paid test payment first |
| 6. Duplicate webhook: no double grant | **Blocked** for a real paid event (D1). Signature checks pass: forged events are refused, and a signed "paid" event for an unpaid session grants nothing |
| 7. Web trial: one per identity, Monthly only | **Pass** |

## Defects, ranked

### D1 (High, blocks the paid test). Staging has no webhook, and staging test payments would reach prod

Evidence:
- `GET /v1/webhooks` with the staging test key lists one webhook: `hook_xDX1i5zipTnQMnEzad4TPbVx`,
  enabled, test mode, URL `https://asia-southeast1-pantas-prod.cloudfunctions.net/paymongoWebhook`,
  events `checkout_session.payment.paid`, `payment.refunded`, `payment.refund.updated`.
- Staging and prod hold the **same** `PAYMONGO_SECRET_KEY` (test) and the **same**
  `PAYMONGO_WEBHOOK_SECRET`, which is that prod webhook's signing secret (compared by equality
  only; no value was printed).
- Prod `paymongoWebhook` is deployed (updated 2026-11-07 14:42 UTC) with those secrets. Prod is in
  test mode, so its livemode check does not drop test events.
- Reading `functions/src/paymongoWebhook.ts`: a staging paid event reaching prod reads the session
  from PayMongo (same account, succeeds), finds no `paymongoOrders/{reference}` in prod, writes
  `paymongoFollowUps/{paymentId}` with reason `unverifiedCheckoutOrPaymentTime`, and returns 500, so
  PayMongo keeps retrying. A staging refund reaching prod writes a `paymongoRevocations/{paymentId}`
  tombstone in prod. Staging itself would receive nothing, so no staging grant would be written.

Suggested fix (needs Aedwon, see below): create a staging test webhook, put its signing secret in
staging, redeploy the staging webhook, and keep the prod test webhook disabled while staging pays.
Longer-term code option (app code, under the freeze): add the Firebase project id to the checkout
metadata, and have the webhook answer 200 without any write for an event whose project id is not
its own. The overlap ends by itself when prod switches to live keys, because a live prod then
ignores test events.

### D2 (Medium). Staging checkout returns the student to the prod app

Evidence: both staging sessions read back from PayMongo carry
`success_url = https://app.pantas.study/pro?checkout=success&ref=...` and
`cancel_url = https://app.pantas.study/pro?checkout=cancelled&ref=...`. Pressing the back arrow on
the PayMongo page navigated to `https://app.pantas.study/pro?checkout=cancelled&ref=fde523d2-...`
(blocked by the test harness, so the prod app was never loaded). Cause: `paymongoCheckout.ts:102`
defaults the origin to `https://app.pantas.study` when `PANTAS_APP_ORIGIN` is unset, and
`functions/.env.pantas-staging` does not set it.

Effect: a staging tester who pays or cancels lands on the prod app, signed out of staging, and
staging's return handling never runs.

Suggested fix: add `PANTAS_APP_ORIGIN=https://staging.pantas.study` to
`functions/.env.pantas-staging` and redeploy `createPaymongoCheckout` on staging. Optionally set
`PANTAS_APP_ORIGIN=https://app.pantas.study` in `functions/.env.pantas-prod` so prod does not rely
on the default. Prod's default is already correct, so this does not block live payments.

### D3 (Medium, needs Aedwon's decision). Checkout shows the merchant's personal legal name

Evidence: sheet 1 and sheet 2 (redacted here because this repository is public). PayMongo's hosted
checkout shows the account's personal legal name in the header and under the line item, not
"Pantas". Every student who buys sees it.

Suggested fix: set the business or display name in the PayMongo account settings before live
activation. This may depend on the merchant verification and business registration in path step 2.
Not an app change.

### D4 (Low). Checkout header shows the internal reference

Evidence: the PayMongo header shows the order reference UUID (for example
`fde523d2-c414-4d70-...`) next to the merchant name. It means nothing to a student.

Suggested fix: check whether PayMongo shows `description` in that place, and if so send a plain
description such as the plan name when creating the session. Low priority.

### D5 (Low, PayMongo side). A failed 3DS card returns to checkout with no message

Evidence: sheet 2, middle. Card `4111 1111 1111 1111` did not decline. It went to PayMongo's
"3DS Test Payment Page" (Authorize, Fail, Cancel). After "Fail Test Payment", PayMongo returned to
the payment method choice with no error shown. The insufficient-funds card `5100 0000 0000 0198`
did show a clear message: "The card has insufficient funds to complete the purchase".

PayMongo's testing page lists `4111111111111111` as a generic decline; in this account it behaves
as a 3DS card. Note for the next run: use `5100000000000198` for the decline test, and never press
"Authorize Test Payment" while D1 is open. Nothing to fix in the app.

### D6 (Low, wording is Aedwon's call). The success return claims a purchase it has not found

Evidence: sheet 3, right. Opening `/pro?checkout=success&ref=...` on staging for an account with no
grant shows "We found a purchase, but Pro couldn't be confirmed yet. Try again in a moment." The
app only saw the return address; it found no purchase. Anyone who opens that address sees the
sentence. The behavior itself is right (no polling, no false Pro).

Suggested fix: wording that does not claim a purchase. In-app copy, so Aedwon picks it.

### Known, already queued (not new)

- The Terms on main still say the free trial is yearly only, subscriptions renew through Apple or
  Google, and refunds go only through Apple or Google (`docs/TERMS.md` section 3 and 4). The web
  sells prepaid PayMongo plans with a Monthly trial. Publishing the new Terms is path step 4 and the
  legal texts work.
- The Astra re-audit of the October 26 and 27 payments fixes is recorded as not run (launch log,
  "Payments and access hardening"). This run did not check whether it ran later.

### Note, not a defect

Email-and-password accounts can never get the web trial: their token lists the identity under
`email`, not `password`, so the server refuses with "A verified sign-in identity is required". The
app offers only Google and email-code sign-in, so students cannot hit this. Staging has the
email/password provider enabled, which is how the test accounts below were made.

## Confirmed working

- Prices served by `listWebPlans` match `docs/pricing.md`: Weekly ₱49, Monthly ₱149, Yearly ₱1,199,
  CSE Professional and Subprofessional passes ₱499.
- Checkout session for CS Monthly: one line item "Pantas Pro, Civil Service, 1 month", 14900 PHP
  centavos, methods card and QR Ph, metadata `uid`, `product`, `reference`, test mode.
- Checkout session for the CSE Professional pass: "Pantas Pro, CSE Professional pass", 49900
  centavos. The order is bound to the CSC-published sitting of 14 March 2027 (source URL stored).
  The Pro page says "₱499 once. Ends after the exam on Mar 14, 2027."
- Asking again for the same plan reuses the open checkout (same session and reference).
- An unknown product is refused: "This product is not sold on the web."
- QR Ph in test mode shows a QR code with a "Simulate Payment" button, so QR Ph success can be
  tested once D1 is fixed. PayMongo warns that its test QR codes are real; do not scan them. The
  QR code is hidden in sheet 1.
- Webhook signature: no signature and a wrong secret both get 401. A correctly signed
  `checkout_session.payment.paid` event naming the unpaid Monthly session got 500, wrote only a
  `paymentNotYetPaid` follow-up, and granted nothing. The event body is not trusted. (That
  follow-up was deleted after the check.)
- Direct loads of the return address now work on staging: `/pro?checkout=...` lands on
  `/settings/pro?checkout=...` with the parameters kept, and the Pro page reacts. This was the
  Nov 3 finding fixed on Nov 4.
- Prod stayed untouched: after the run, prod `paymongoFollowUps`, `paymongoRevocations`,
  `paymongoPayments` and `paymongoOrders` are all empty, and prod `paymongoWebhook` has no request
  logged on 9 November.

### Web trial (step 7)

- A new email-code-style account (custom token, verified email) is trial-eligible. The Pro page
  shows "7 DAYS FREE" on Monthly only and the button "Try 7 Days Free / No payment needed."
  Picking Weekly changes the button to "Buy 1 Week for ₱49" with no trial.
- After "Try 7 Days Free": the ledger has `users/{uid}/grants/trial`, source `trial`, product
  `web_trial`, tier `civilService`, active, exactly 7.0 days, ending 2026-11-16 11:07 UTC. The app
  shows "You're on Pro. Plan: Monthly trial. Ends Nov 16, 2026. Your free trial ends on Nov 16,
  2026. You won't be charged."
- Second try on the same account: `trialEligible` false, `startWebTrial` refused with "The free
  trial was already used."
- Same email, new account (old Auth account deleted, a new one made with the same address):
  `trialEligible` false, `startWebTrial` refused with "The free trial was already used." The Pro
  page shows no trial badge and "Buy 1 Month for ₱149".

## What Aedwon must do to unblock steps 3, 5 and 6

From PayMongo's docs ("Creating a webhook endpoint" and the dashboard module pages on
docs.paymongo.com). In the PayMongo dashboard, **test mode**:

1. Go to Developer Tools, then Webhooks.
2. In that list, **disable** the existing webhook for `pantas-prod` for the duration of the staging
   run. Re-enable it afterwards. (The docs do not show where the disable control sits; it is a
   dashboard setting on the webhook. PayMongo's API also has a disable call.)
3. Click Add Endpoint. URL: `https://asia-southeast1-pantas-staging.cloudfunctions.net/paymongoWebhook`
   (this URL reaches the staging function; it answered 401 to an unsigned test post).
4. Select the same events as the prod webhook: `checkout_session.payment.paid`,
   `payment.refunded`, `payment.refund.updated`. Add `dispute.created` and `dispute.resolved` if
   the dashboard offers them.
5. Save. Copy the new webhook's signing secret.
6. In a terminal: `firebase functions:secrets:set PAYMONGO_WEBHOOK_SECRET --project pantas-staging`
   and paste it. Then tell the agent, which redeploys the staging webhook so it uses the new version,
   sets `PANTAS_APP_ORIGIN` for staging (D2) with your approval, and reruns steps 3, 5 and 6.

Options for step 2, with costs:

- **Disable the prod test webhook during the run (recommended).** Two clicks. Cost: test-mode
  checkouts on prod would not grant during that window; no one buys on prod now.
- Leave it on. Cost: every staging test payment and refund writes records in prod Firestore, and
  PayMongo keeps retrying the failed prod delivery. This breaks the prod read-only rule.
- Fix it in code first (D1's project-id check). Cost: an app-code change under the freeze, a review
  and two deploys before the test can run.

An agent can also create the staging webhook through PayMongo's API with the test key, which
returns its secret directly. That is an external change to the PayMongo account, so it needs
Aedwon's explicit approval.

## What blocks live payments

1. The paid flows have never run end to end: grant on payment, refund and partial refund, and the
   duplicate webhook. Needs D1 fixed, then a rerun on staging.
2. PayMongo live activation, live keys, a live webhook, and one real small payment (path steps 2
   and 3).
3. The merchant name on checkout (D3), decided before live.
4. The Terms and refund text for web payments published (path step 4).
5. The payments re-audit, if it is still outstanding.

## Method

- Headless Chromium (Playwright core, `chrome-headless-shell` 1248) under the Nov 9 screenshot
  exemption. One sheet per flow. Every browser was closed after its capture. No computer control.
- App Check: one debug token registered on the staging web app ("paymongo test-mode run (Nov 9;
  delete after)"), injected into the page, and **deleted** at the end. The other lead's token from
  the DS4 visual pass is still registered; it is not this run's to remove.
- Accounts: staging has no mail key, so the email code cannot be received there. Test accounts
  were made directly in staging Auth:
  - A `GyymYUSPvGRhl2W7aklJMQc7rav1` (email and password, `@example.com`): checkout calls.
  - B `06kSHdixk9VGHfx7IL8rZaUAfvh1`: unused, deleted.
  - C `3cAgPQbhY7eyFClZwB2oyIQuV5e2` (custom token, like an email-code account): took the trial.
    Auth account deleted for the identity test; its Firestore data stays as evidence.
  - D `qypIZwm55YXnheEGfJUxxVFbfPv2` (custom token, same email as C): trial refused, failed-card
    test, Pro page and return captures.
- Custom tokens were signed through IAM. That needed a temporary Service Account Token Creator
  role for Aedwon's Google account on the staging `firebase-adminsdk-fbsvc` service account. It was
  **removed** at the end (verified: the account no longer appears in that service account's policy).
- Prod access was read only: function and secret metadata, an equality check of secret values (no
  value printed or stored), Firestore collection reads and the webhook log.
- PayMongo test sessions left open (test mode, they expire on their own): Monthly
  `cs_97cb9c4643ff14026f336112` and pass `cs_ee191778b06d34c7fadceed5` (account A); Monthly
  `cs_ebb293c97847b522e527fb25` and pass `cs_2a02ceb7f61b5e008f02bfe0` (account D). The D Monthly
  session holds two failed payments.

## Evidence sheets

In `evidence/test-mode-run-2026-11-09/`. The merchant name and the QR code are blacked out.

1. `1-checkout-start.png`: Pro page with Monthly, PayMongo Monthly ₱149, Pro page with the
   Season Pass, PayMongo pass ₱499, QR Ph test mode.
2. `2-failed-card.png`: the 3DS test page, the page after "Fail Test Payment", and the
   insufficient-funds message.
3. `3-return-pages.png`: staging `/pro?checkout=cancelled` and `/pro?checkout=success` with no grant.
4. `4-web-trial.png`: trial offered on Monthly only, Weekly without trial, Pro after the trial,
   and the same email on a new account with no trial.
