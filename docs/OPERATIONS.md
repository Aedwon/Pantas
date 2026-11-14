# Operations status tracker

> **Pricing (4 October 2026).** The Student-tier prices and product IDs here are current. Prices now differ by exam tier, and other tiers need new products. The only full price list is `docs/pricing.md`.

Tracks long-pole external dependencies and one-time manual configuration. Owner: Aerol Balayon.

Last updated: 2026-05-07

## Pending things and ideas

When Aedwon asks for pending things, include `docs/future/README.md`, the index of archived and pending ideas, alongside the manager queue in the launch log.

## Day-1 procedural items (Phase A of Plan 1)

| # | Item | Status | Started | Expected complete | Notes |
|---|---|---|---|---|---|
| 1 | NPC registration filed | [ ] | 2026-05-07 | 2026-06-25 (latest) | Reference number: TBD; follow-ups 2026-05-21, 2026-06-04, 2026-06-18 |
| 2 | Apple Developer Program | [ ] | 2026-05-07 | 2026-05-09 | Team ID: TBD |
| 3 | Google Play Console | [ ] | 2026-05-07 | 2026-05-10 | Account ID: TBD |
| 4 | Pentester engaged for week 6 | [ ] | 2026-05-07 | 2026-05-12 (signed) | Vendor: TBD; window: 2026-06-11 to 2026-06-17 |

## Vendor reference info

### Firebase

- Dev project: `cse-cet-reviewer-dev` (number: TBD)
- Prod project: `cse-cet-reviewer-prod` (number: TBD)
- Region: `asia-southeast1` (Singapore)
- Blaze plan enabled on both, $10/mo budget alert configured
- Hosting placeholder URLs:
  - Dev:  https://cse-cet-reviewer-dev.web.app
  - Prod: https://cse-cet-reviewer-prod.web.app

#### User-data sync setup

- [x] **Deploy Firestore owner rules. Done 12 August 2026**, to all three
  projects: `pantas-dev-090126`, `pantas-staging`, `pantas-prod`. Each reported
  "released rules firestore.rules to cloud.firestore".
- [ ] **Storage rules are not deployed.** No bucket exists yet, and the deploy
  fails without one. Do it when Cloud Storage is turned on.
- [ ] Validate App Check enforcement for Firestore and Functions in dev and
  prod after debug tokens and Play Integrity are registered.
- [ ] Run one real-device sync verification before release: create local
  progress, sign in, choose "keep this device", reinstall, sign in again,
  choose "keep my account", and confirm progress restores.
- [ ] Confirm `content.db` remains out of user-data sync scope. It is
  regenerable Sanity content; only `app.db` user-data rows sync to Firestore.

### Sanity

- Project ID: TBD
- Datasets: `production` (dev plan also uses this for v0; isolated `staging` ds added in Plan 4)
- 2FA enforced at org level: [ ] confirm
- API token (read-only, dev): stored in 1Password under "CSE/CET Reviewer — Sanity Dev"

### RevenueCat

**Corrected 11 August 2026.** This section listed a lifetime product and the old
app name. **Do not create products from the old list.** Full setup, in order, is
`docs/revenuecat-setup.md`.

- Project: Pantas
- Entitlement: `pro`
- **Products, settled 12 August 2026: `pantas_pro_weekly`, `pantas_pro_monthly`,
  `pantas_pro_yearly`.** Three separate subscriptions, one per billing period,
  not one subscription with three base plans. **The same three strings are
  hardcoded in the RevenueCat gateway and must not drift from these.**
- **No lifetime product**, removed by decision on 3 August 2026. A Play product ID
  cannot be deleted once used, so creating one would be permanent.
- Prices: ₱29 weekly, ₱99 monthly, **₱799 yearly**, lowered from ₱999 on 11 August 2026
- Android only. There is no Apple developer account, so no App Store side exists.
- Webhook secret: stored in 1Password under "Pantas, RevenueCat Webhook"

### Contact, set 11 August 2026

- **Privacy and data requests: `dpo@pantas.app`.** Printed on the privacy page
  and opened by the "Contact our DPO" row.
- **Play listing contact: `contact@pantas.app`.** Play requires a developer
  contact email and a community group does not satisfy it. No row in the app
  points at this address.
- **Feedback: the Facebook group**,
  `https://www.facebook.com/groups/1760794271928040`, created 11 August 2026.
  This is where the "Send feedback" row goes. It is a moderation commitment.
- **Beta feedback: not the Facebook group.** For the beta, the group does not
  apply (Aedwon, 9 November 2026). Testers send feedback through the in-app
  Settings page Feedback (Beta). Reports are stored in pantas-prod Firestore at
  `users/{uid}/betaFeedback/{id}`, with images in Storage at
  `betaFeedback/{uid}/{feedbackId}/`. Aedwon reads them in the Firebase console;
  there is no admin screen.
- **Outgoing email: Aedwon gets it first (Nov 9).** Before any email an agent sends
  (beta, results, guardian, marketing, one-off transactional) reaches anyone, the exact
  final email goes to aerol.balayon@gmail.com alone, and the real send waits for his
  confirmation that he received and checked it, even if he said "send" earlier. Product
  mail such as sign-in codes and guardian requests is exempt. Rule 6 in
  `docs/workflow/process-improvement.md`.
- **No postal address.** There is no office, and a placeholder under a privacy
  policy is worse than none. The Play Console asks for an address when a
  developer account is verified. That is the console's, not the app's.

### Apple Developer

**None held as of 11 August 2026**, so nothing iOS is set up and nothing needs to
be. The bundle IDs previously listed here were three guesses that did not match the
one actually in the Xcode project, `com.aedwon.pantas`. Left here only so
nobody treats the old list as configured.

Blocked on an Apple account, and only when iOS matters: Apple sign-in, App Attest,
the APNs key, and per-flavor bundle IDs so a dev and a prod build can coexist on
one iPhone.

### Google Play

- Developer account: held.
- **Application ID: `com.aedwon.pantas`**, with `.dev` and `.dev.staging` for the
  other flavors. Set 11 August 2026 and **permanent from the first submission.**
- **A Google Cloud service account must be invited into Play Console** before
  RevenueCat can read subscriptions. This is the step that fails quietly. See
  `docs/revenuecat-setup.md` Section 3.

#### Done 12 August 2026

- **Google Cloud project: `pantas-090126`**, owned by the same account as Play.
  It was not linked to Play Console, and it does not need to be.
- **Service account: `revenuecat-play@pantas-090126.iam.gserviceaccount.com`**,
  with Pub/Sub Editor and Monitoring Viewer.
- **Three APIs enabled**: Google Play Android Developer, Google Play Developer
  Reporting, Cloud Pub/Sub.
- **Invited into Play Console and showing Active**, with all three permissions.
  **The 36-hour clock started here.**
- **The JSON key is on Aedwon's Mac and nowhere else.** Not in this repo, not in
  any cloud folder shared with anyone. A replacement takes a minute, so it is
  deleted rather than kept once RevenueCat has it.

#### Still open on the Play side

- **Identity verification and the device check are unfinished.** They block
  production, and possibly the products themselves. Nothing done so far needed
  them.
- The RevenueCat project, the products and the real-time notifications all wait
  on `purchases_flutter` 10 and an internal testing build.

## Manual configuration steps

These cannot be scripted in this repo and must be redone if the relevant config is regenerated.

- [ ] iOS Xcode schemes created (`Runner-Dev`, `Runner-Staging`, `Runner-Prod`) with xcconfigs from `ios/Flutter/{Dev,Staging,Prod}.xcconfig` — Plan 1 Task 6 step 8
- [ ] iOS "Copy GoogleService-Info.plist" run-script phase added to Runner target — Plan 1 Task 16 step 4
- [ ] Sanity 2FA enforcement at org level enabled — Plan 1 Task 19 step 4
- [ ] GitHub branch protection on `main` — Plan 1 Task 28 step 2

## Manual QR Ph refund

PayMongo's refund API refuses QR Ph payments ("Refunds are not allowed for payments with source
type qrph", test mode, 9 November 2026). Aedwon's ruling: refund QR Ph buyers by bank transfer,
then record the refund so access matches. Report:
`docs/superpowers/plans/paymongo/test-mode-run-2026-11-09.md` on `ops/paymongo-test-r1`.

**Never edit a grant in the Firestore console.** It leaves the student's Pro status, later
stacked grants and sign-in claims out of step. Use the command below. It sends a signed
`payment.refunded` event for the money you returned, so the webhook's own refund logic runs:
a partial amount shortens access in proportion, amounts that add up to the price revoke it, and
later queued plans move earlier. Tested on staging, 9 November 2026.

1. **Find the payment.** In the PayMongo dashboard, open the payment and copy its id
   (`pay_...`) and amount. In Firestore, `paymongoPayments/<pay_ id>` gives the student's `uid`.
2. **Send the money** by bank transfer. Keep the bank's reference number.
3. **Save the command** below as `manual-refund.mjs` anywhere outside the repository.
4. **Run it** with the project, the `pay_` id, the amount you returned **in centavos**
   (₱499 is `49900`), and a new label made of letters, digits and `_`, for example `20261120_1`.
   Prod in live mode:

   ```sh
   export PAYMONGO_WEBHOOK_SECRET="$(gcloud secrets versions access latest --secret PAYMONGO_WEBHOOK_SECRET --project pantas-prod)"
   export PAYMONGO_LIVEMODE=true   # false while the project runs a sk_test_ key
   node manual-refund.mjs pantas-prod pay_XXXX 49900 20261120_1
   unset PAYMONGO_WEBHOOK_SECRET
   ```

   `HTTP 200 recorded` means it applied. The label is the refund's id: sending the same label
   again changes nothing, so a retry is safe. **Never reuse a label for a different refund.**
5. **Check** `users/<uid>/grants/<pay_ id>`: `refunds` lists `manual_<label>`, and `state` is
   `revoked` (full) or `endsAt` moved earlier (partial).
6. **Record it** outside the repository (it is student data): date, student public id or `uid`,
   `pay_` id, amount, bank reference, label, and reason.

```js
// manual-refund.mjs. Records a refund made outside PayMongo through the webhook's refund path.
// PAYMONGO_WEBHOOK_SECRET=... PAYMONGO_LIVEMODE=true|false node manual-refund.mjs <project> <pay_ id> <centavos> <label>
import {createHmac} from 'node:crypto';
const [project, paymentId, amountText, label] = process.argv.slice(2);
const amount = Number(amountText);
const secret = process.env.PAYMONGO_WEBHOOK_SECRET;
const livemode = process.env.PAYMONGO_LIVEMODE === 'true';
if (!/^pantas-(prod|staging)$/.test(project ?? '') || !/^pay_[A-Za-z0-9]+$/.test(paymentId ?? '') ||
    !Number.isInteger(amount) || amount <= 0 || !/^[A-Za-z0-9_]{6,60}$/.test(label ?? '') || !secret ||
    !['true', 'false'].includes(process.env.PAYMONGO_LIVEMODE)) {
  console.error('Check the arguments: project, pay_ id, centavos, label (letters, digits, _), PAYMONGO_LIVEMODE.');
  process.exit(2);
}
const refundId = `manual_${label}`;
const body = JSON.stringify({data: {id: `evt_${refundId}`, type: 'event', attributes: {
  type: 'payment.refunded', livemode, data: {id: paymentId, type: 'payment', attributes: {
    refunds: [{id: refundId, attributes: {amount, status: 'succeeded'}}]}}}}});
const t = Math.floor(Date.now() / 1000);
const mac = createHmac('sha256', secret).update(`${t}.${body}`).digest('hex');
const signature = livemode ? `t=${t},te=,li=${mac}` : `t=${t},te=${mac},li=`;
const response = await fetch(`https://asia-southeast1-${project}.cloudfunctions.net/paymongoWebhook`,
  {method: 'POST', headers: {'Content-Type': 'application/json', 'Paymongo-Signature': signature}, body});
console.log(`${refundId}: HTTP ${response.status}`, response.status === 200 ? 'recorded' : 'NOT recorded, see the function log');
```

If PayMongo support later confirms a way to refund QR Ph through PayMongo, use that instead: its
refund event then reaches the webhook by itself.

## Codemagic / signing (activated in Plan 8)

- [ ] iOS App Store Connect API key uploaded
- [ ] iOS distribution certificate uploaded
- [ ] Android upload keystore generated and uploaded
- [ ] Google Play service account credentials uploaded

## Usage digest (private)

Answers three questions about people who chose "Help improve Pantas by sharing usage data": where their visits end, which screen they open first, and how much each screen is used. Added 14 November 2026.

```bash
node tools/telemetry/usage_digest.mjs                       # last 7 days, project pantas-prod
node tools/telemetry/usage_digest.mjs --days 14 --project pantas-prod
```

- Needs the `gcloud` CLI signed in with permission to read logs on the project. Logs are kept 30 days, so `--days` is at most 30.
- Reads the `usage_visit` log lines written by the `reportUsageVisit` callable. A line holds a random visit id, screen names and times. It holds no account id, no email and no free text.
- Writes one Markdown file to `~/Library/Application Support/Pantas/usage-digests/`, or to the folder in `PANTAS_PRIVATE_DIR`. It refuses a folder inside the repository. It prints only the file path and the totals.
- **Never copy a digest or any usage record into the repository.** Tester data stays out of it. Tests use fake visits only.
- Needs the `reportUsageVisit` callable deployed. Until then, no records exist and the digest says so.

## Compliance checklist

- [ ] NPC registration confirmation received and recorded
- [ ] Privacy Policy reviewed by PH data privacy lawyer
- [ ] Terms of Service reviewed by PH lawyer
- [ ] App Store privacy nutrition labels filled (Plan 8)
- [ ] Google Play data safety form filled (Plan 8)
- [ ] DTI Business Name Registration confirmed (if operating under business name)

## Pentest

- [ ] Engagement signed
- [ ] NDA signed
- [ ] Scope finalized
- [ ] Engagement window: 2026-06-11 to 2026-06-17
- [ ] Findings report delivered
- [ ] Critical / High remediations done

## Cost controls

Added 2 November 2026. Aedwon approved the design; the numbers may be tuned.
Code: `functions/src/content.ts`, `_contentCeiling.ts`, `_options.ts`.

| Control | Value | Where |
|---|---|---|
| Delivered lessons and question sets, per account, rolling 24 hours | 300 | `DAILY_CONTENT_IDS` |
| Delivered catalog documents, per account, rolling 24 hours | 200 | `DAILY_CATALOG_IDS` |
| Ids asked about (delivered or not), per account, content | 1000 | `DAILY_CONTENT_REQUESTS` |
| Ids asked about (delivered or not), per account, catalog | 1000 | `DAILY_CATALOG_REQUESTS` |
| Delivered lessons and question sets, all accounts, per Philippine day | 200,000 | `DAILY_DELIVERED_CEILING` |
| Instances per function | 10 | `DEFAULT_MAX_INSTANCES` |
| Instances, payment webhooks | 30 | `WEBHOOK_MAX_INSTANCES` |
| Instances, account deletion | 20 | `ACCOUNT_DELETION_MAX_INSTANCES` |

- Only content that is sent costs against the delivered limits. A version check
  that returns "unchanged" or "missing" does not.
- Accounts with paid access to the requested exam skip the shared ceiling. Their
  deliveries still count in its total, and their own limits still apply.
- The ceiling can be changed without a code change: set `DAILY_CONTENT_CEILING`
  in `functions/.env` and deploy.
- All content limits return the same error: "Daily content limit reached. Try
  again tomorrow."
- The app asks the server about an item once per local day and again at once
  when the account or what it has paid for changes.
- Alert lines to match in Cloud Logging: `Daily content ceiling reached 80%`
  and `Daily content ceiling reached.`
- Console steps that code cannot do: `build/cost-controls.md` in the
  staging-candidate worktree.
