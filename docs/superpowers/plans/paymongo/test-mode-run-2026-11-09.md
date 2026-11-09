# PayMongo test-mode run on staging, 9 November 2026

**Run by:** Claude Opus 5.5 (lead, launched by the manager thread), branch `ops/paymongo-test-r1`.
**Policy commit:** `44576bfdb` (main). **Target:** https://staging.pantas.study, Firebase project
`pantas-staging`, PayMongo **test mode** only. No real money moved. Prod was read only.
**Why:** Aedwon asked whether PayMongo was ever tested. It was not. He queued this run:
"okay, put that in the queue first hehe" (launch log, "PayMongo readiness and the manager queue").

## Rerun after Aedwon's approval (9 November, 19:25 to 19:55 PHT)

The manager relayed Aedwon's approval to fix the staging setup and rerun ("1. ok"). This section
supersedes the first-run verdict below. The first run stays as written.

| Step | Result |
|---|---|
| 1. Sign in | **Pass** (new staging accounts E, F, G) |
| 2. Checkout: Monthly by test card, Season Pass by QR Ph "Simulate Payment" | **Pass** |
| 3. Grant period, Pro unlock, return page | **Pass** |
| 4. Failed card | **Pass** (first run, unchanged) |
| 5. Full and partial refund | **Pass** for card payments. QR Ph payments **cannot be refunded** through PayMongo's API (D7) |
| 6. Duplicate webhook | **Pass** |
| 7. Web trial | **Pass** (first run, unchanged) |

### Setup changes (approved)

- **Staging webhook created through the API:** `hook_7hTDS2YqdbvnvGrujHn3eULN`, test mode, URL
  `https://asia-southeast1-pantas-staging.cloudfunctions.net/paymongoWebhook`, events
  `checkout_session.payment.paid`, `payment.refunded`, `payment.refund.updated`. It stays enabled.
- **Its signing secret** went straight from the API response into staging `PAYMONGO_WEBHOOK_SECRET`
  version 2 without being printed. Version 1 (the prod webhook's secret) is still stored but unused.
- **Return address (D2) fixed by config, not app code:** `PANTAS_APP_ORIGIN=https://staging.pantas.study`
  added to `functions/.env.pantas-staging` on this branch. Staging is deployed from
  `web/design-system-4`, so this line must reach that branch, or the next functions deploy from it
  drops the setting and staging returns to the prod app again.
- **Redeploy, payment functions only:** a direct Cloud Run update was tried first, to keep the exact
  Nov 8 build. It failed: the Nov 8 function image had been cleaned out of Artifact Registry. So
  `createPaymongoCheckout` and `paymongoWebhook` were rebuilt and deployed from this branch
  (`firebase deploy --config firebase.staging.json --only functions:createPaymongoCheckout,functions:paymongoWebhook`)
  at 2026-11-09 11:28 UTC. `functions/src` is identical to the Nov 8 deploy. The only other
  difference is the functions dependency fixes (osv), already merged into `web/design-system-4`.
  Verified after deploy: the webhook reads secret version 2, and both functions carry
  `PANTAS_APP_ORIGIN=https://staging.pantas.study`.
- **Prod test webhook** `hook_xDX1i5zipTnQMnEzad4TPbVx` disabled through the API at 11:29:07 UTC and
  enabled again at 11:54:18 UTC. Verified afterwards: enabled, same URL, same three events, test mode,
  identical to the state recorded before.

### Results

**Monthly by card (account E, `bvxshuH4b4UxcdAW0PzaZdAoL063`).** Card `4343 4343 4343 4345` paid
₱149 with no 3DS step. PayMongo returned the browser to
`https://staging.pantas.study/pro?checkout=success&ref=...`, which the app kept as
`/settings/pro?checkout=success&ref=...`. One webhook delivery, 200, about 14 seconds after payment.
Grant `pay_89YFTBe9n2zfLqLrriiS52R4`: starts at payment, 2026-11-09 19:35:04 PHT, ends
2026-12-09 19:35:04 PHT. That is one calendar month in Manila time, as `docs/pricing.md` sells
Monthly. Entitlement record `pro: true`, version 1, claims copied (claimsVersion 1). The app showed
"You're on Pro. Plan: Monthly. Ends Dec 9, 2026." (sheet 5).

**Season Pass by QR Ph (account F, `Xb8hbZgPhcUm9g6c9asat0ylk5m2`).** "Simulate Payment" opens a
separate "QRPH Test Payment Page" with Authorize, Fail and Expire. "Authorize Test Payment" paid
₱499; checkout returned to staging. Grant `pay_qvoXMQvF5UgyRTxK7u2fkegy`: starts at payment, ends
2027-03-14 23:59:59 PHT, the end of the CSC exam day, matching the pricing record ("valid to the next
exam date") and the Terms ("ends after that exam's date"). The app showed "Plan: Season Pass. Exam:
CSE Professional. Ends Mar 14, 2027. A one-time purchase. It ends after the exam and never renews."
(sheet 6).

**Partial refund.** A ₱74.50 refund (half) on E's Monthly. The grant kept its full end in
`fullEndsAt` (Dec 9) and `endsAt` moved to 2026-11-24 19:35:04 PHT, exactly half of the 30-day
length, per the Oct 19 decision. Entitlement version 2.

**Refunds adding up to the full amount.** A second ₱74.50 refund on the same payment. The grant became
`revoked` (reason `payment.refund.updated`), with both refund ids recorded. Entitlement `pro: false`.

**Single full refund.** E then bought Weekly (₱49, card). Grant 2026-11-09 19:51:39 to
2026-11-16 19:51:39 PHT (7 days). A ₱49 refund revoked it (reason `payment.refunded`), `pro: false`,
version 5. The app shows the plans again with "Buy 1 Month for ₱149" (sheet 5).

**Duplicate webhook.** The real paid event `evt_BC6gNpcaRf3hWwdv5FYnZ5kS` was replayed twice, and a
third event with a new id for the same payment was sent, all correctly signed. All three answered
200. The ledger still had one grant and the entitlement version stayed at 1. PayMongo also produced
a natural duplicate: each refund arrived as two events (`payment.refunded` and
`payment.refund.updated`) in the same second. Each refund was counted once.

**Prod.** Read only, after the prod webhook was enabled again: `paymongoFollowUps`,
`paymongoRevocations`, `paymongoPayments`, `paymongoOrders` and `webhookEvents` are empty, and prod
`paymongoWebhook` logged no request on 9 November.

### New defects from the rerun

**D7 (High, needs Aedwon's decision). QR Ph payments cannot be refunded through PayMongo's API.**
`POST /v1/refunds` for F's QR Ph payment returned `parameter_invalid`: "Refunds are not allowed for
payments with source type qrph." The refund policy promises full refunds for errors (double charge,
payment that did not unlock Pro), and the server flags duplicate pass payments for a refund. A
student who paid by QR Ph cannot be refunded that way, and no refund event would ever revoke the
grant. Not checked: whether the dashboard allows it, and how live mode behaves. Options: ask PayMongo
support; refund QR Ph buyers by bank transfer with a manual revoke (needs an admin path, which does
not exist now); or drop QR Ph from checkout. Aedwon chose bank transfer plus a manual revoke (rulings below).

**D8 (Medium, operations). A refund fails when the available balance is lower than the refund.**
A one-shot ₱499 refund on G's card-paid pass returned `available_balance_insufficient`: "Refund
amount is greater than the available payout amount." In live mode, after a payout empties the
balance, a refund would fail the same way until new payments arrive. The runbook should say so.
G's pass (`pay_68hLPwvXknkmYFUAgqL8jPzA`) stays active on staging.

**D1 status.** Fixed for this run. Both test webhooks are now enabled, so while prod still runs test
keys, a staging test payment again reaches prod. Future staging payment runs must disable the prod
test webhook first, or the code fix in D1 must land. When prod moves to live keys, prod ignores
test events.

**D2 status.** Fixed on staging (config above).

### What blocks live payments now

1. QR Ph refunds (D7): a decision before selling with QR Ph.
2. PayMongo live activation, live keys, a live webhook, and one real small payment (path steps 2
   and 3).
3. The merchant name on checkout (D3, answer below).
4. The Terms and refund text for web payments published (path step 4).
5. The payments re-audit, if still outstanding.

### Merchant name: what PayMongo's docs say

Sources: docs.paymongo.com, read 9 November 2026. PayMongo's site links no separate help center; it
points to support@paymongo.com and the dashboard's "Reach the Team" chat.

- **Read from the account:** every checkout session reports `merchant` as the personal legal name
  and `statement_descriptor` as null. `GET /v1/accounts` returned an empty list; it is for platform
  child accounts. The account's own business profile could not be read with the API.
- **Can checkout show a trade name?** Not documented. The Checkout Session resource has `merchant`
  and `statement_descriptor` fields, both "Paymongo Test Account" in the sample, but no page says how
  they are set, and the create request has no name or descriptor field
  (`reference/checkout-session-resource.md`, `docs/payment-channels-hosted-checkout.md`).
- **Card statement:** no statement-descriptor setting is documented.
- **Where a business name lives:** account activation (KYB) asks for "Legal/trade name and business
  description" (`docs/account-settings-account-setup.md`). Business type and the upgrade from
  Individual are under Settings, Business Information (`docs/account-settings-business-types.md`).
  "Your business type can only be set once."
- **DTI:** a sole proprietorship account requires the "DTI Certificate of Business Name
  Registration", the owner's government ID and the BIR Certificate of Registration (Form 2303)
  (`docs/account-settings-philippine-entities.md`). An Individual account is for "businesses not
  registered with DTI". The docs do not say outright that a trade name needs DTI. A DTI business name
  is the document they list for a sole proprietor's business name.
- **Hiding the personal name, even partly:** not documented.
- **Payment Pages (Storefront)** do take a page name that customers see and that appears on receipts
  (`docs/payment-channels-storefront.md`). That is a different product, not Hosted Checkout.

Clicks for Aedwon (no change was made):

1. PayMongo dashboard, Settings, Business Information: check the business type and the business or
   trade name on file.
2. If the account is Individual and he wants "Pantas" or "Pantas Online Tutorial Services" shown,
   that name needs DTI registration first; then upgrade to Sole Proprietorship in the same place with
   the DTI certificate, BIR 2303 and ID.
3. Ask PayMongo through "Reach the Team": "Which name does Hosted Checkout show as merchant, and
   what appears on card statements? Can both be my DTI trade name, without my personal name?"

Not confirmed: which name checkout shows after an upgrade, whether a statement descriptor can be
set, and whether the personal name can be hidden. Only PayMongo support can confirm these.

### Aedwon's rulings on D7 and the merchant name (9 November)

Verbatim, relayed by the manager: "okay with A. i can do manual transfers / for the name, my
PayMongo account is still in individual mode, not sole proprietor since i still don't have my BIR
COR. with that said, can we keep my name out or not? lean on keeping out my name, but if it's
inevitable then i guess we have no choice".

- **D7 decision:** a QR Ph refund goes out by manual bank transfer, and Aedwon then shortens or
  revokes access by hand. He also asks PayMongo support whether the API can refund QR Ph (draft
  below). Runbook: `docs/OPERATIONS.md`, "Manual QR Ph refund".
- **Manual revoke tested on staging.** The runbook's command sends a signed `payment.refunded`
  event for a refund made outside PayMongo, so the webhook's own refund logic runs: the grant,
  later stacked grants, Pro status and sign-in claims update together. On F's QR Ph pass
  (`pay_qvoXMQvF5UgyRTxK7u2fkegy`, ₱499): a ₱249.50 manual refund shortened the pass from
  14 March 2027 23:59:59 to 11 January 2027 09:50:37 PHT (half its length); the same label sent
  again changed nothing; a second ₱249.50 revoked it and set `pro: false`. Editing a grant in the
  Firestore console is not safe: it leaves the Pro status, stacked grants and sign-in claims stale.

### Going live: recommendation

**Do not take live payments while the PayMongo account is in Individual mode.** Wait for the BIR
Certificate of Registration, the DTI business name, and the upgrade to a Sole Proprietorship
account. Reasons:

- PayMongo documents no way to show a store name, or to hide the owner's name, on Hosted Checkout
  or card statements. Today every checkout reads the legal name in its `merchant` field. The only
  documented way to put a business name on the account is the DTI-registered name that a sole
  proprietor account requires. Whether checkout then shows it is for PayMongo support to confirm
  (message 1 below).
- Selling before the COR also leaves no BIR-registered invoices to issue for those sales.
- PayMongo's docs list online card and e-wallet acceptance among registered-account features, not
  Individual ones (`docs/account-settings-business-types.md`). This was not tested in live mode.

What our code already controls, checked in `functions/src/paymongoCheckout.ts` and
`paymongoClient.ts`:

- **Line items:** every product is named "Pantas Pro, ..." ("Pantas Pro, Civil Service, 1 month",
  "Pantas Pro, CSE Professional pass", and so on). Already Pantas.
- **Description:** the code sends no `description`. PayMongo shows none (read back as null).
- **Reference number:** the code sends the order UUID as `reference_number`, and checkout shows it
  in the header next to the merchant name (D4).
- **Merchant name and statement descriptor:** not sent by the code. The create request documents
  no field for either, so the code cannot change them.

If PayMongo says the account name is shown regardless, the name appears on checkout; Aedwon has
accepted that if it is unavoidable.

### Messages for Aedwon to send through "Reach the Team" (drafts, not sent)

**Message 1, the name shown to buyers.**

> Hi PayMongo team. My account is in Individual mode. On Hosted Checkout (checkout sessions) the
> merchant name shown to buyers is my full legal name. Can an Individual account show a store or
> display name instead, on checkout and on the buyer's card statement? If not, after I upgrade to a
> Sole Proprietorship with a DTI business name, will checkout and card statements show the DTI
> business name only, without my personal name? Is there a setting or API field for the
> statement descriptor? Thank you.

**Message 2, refunding QR Ph payments.**

> Hi PayMongo team. When I call POST /v1/refunds for a payment made with QR Ph through Hosted
> Checkout, the API returns "Refunds are not allowed for payments with source type qrph." Is there
> any way to refund a QR Ph payment, through the API or the dashboard, in test or live mode? If
> not, what is the recommended way to return money to a QR Ph buyer, and is it the same after the
> account is upgraded to a Sole Proprietorship? Thank you.

### Staging data left by the rerun

Accounts E `bvxshuH4b4UxcdAW0PzaZdAoL063` (Monthly revoked, Weekly revoked), F
`Xb8hbZgPhcUm9g6c9asat0ylk5m2` (QR Ph pass, revoked by the manual refund test), G
`JPpkb0SWFrRf58i6YtznlGIGfw82` (pass active, card, refund refused for balance). Temporary access
removed: the App Check debug token "paymongo test-mode rerun (Nov 9; delete after)" was deleted; no
IAM role was added in the rerun. The staging webhook stays enabled. All browsers were closed.

Sheets 5 and 6 are in the evidence folder:
`5-card-monthly-and-refunds.png` and `6-qrph-season-pass.png`.

## First run verdict (superseded by the rerun above)

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
