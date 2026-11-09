# Deploy the free beta to pantas-prod

For Aedwon, after Blaze is available. This is a runbook, not evidence of deployment.
All console changes, secret handling, live commands, DNS changes, and smoke tests
below are **Aedwon-only**. Run commands from the reviewed release checkout.
Do not run these steps until the lead accepts that candidate and Aedwon approves release.

The beta runs November 9 through 15, 2026. The temporary Pro switch must end at
00:00 November 16, Asia/Manila. PayMongo stays in test mode. The switch is a
separate server-gated feature; this configuration change does not implement it.

## 1. Billing and project checks (Aedwon-only)

1. Link the same Cloud Billing account to `pantas-prod` and `pantas-staging`.
   Confirm both projects show Blaze. A billing account is shared, not a Firebase project.
2. Create a budget alert for those projects. Choose the amount and alert thresholds
   yourself. Confirm your email receives notifications. Alerts do not cap spending.
3. In the prod console, confirm Firestore, Authentication and Storage are configured.
   Preserve the existing `betaApplications` collection and the Cloudflare Worker's
   server access. Do not replace its credentials or import over its data.
4. Confirm the Firebase web app is
   `1:416041343210:web:cdf805fbfb28ca13639f93`. Its public config is already in
   `lib/firebase_options_prod.dart`. The prod entry point is `lib/main_prod.dart`.
5. Enable the required Auth providers. Add `app.pantas.study` and the confirmed
   app Hosting domain to Authentication > Settings > Authorized domains.

## 2. App Hosting site

Done. pantas-prod has one Hosting site, `pantas-prod` (https://pantas-prod.web.app), checked with
`firebase hosting:sites:list --project pantas-prod` on Oct 30. The app uses it; `.firebaserc` maps
the `app` target to it. pantas.study stays on the Cloudflare site, and app.pantas.study is connected
to this site in step 9.

## 3. Prepare test-mode secrets (Aedwon-only)

The beta end time is not a secret: `functions/.env.pantas-prod` sets
`BETA_PRO_UNTIL=2026-11-16T00:00:00+08:00` and deploys with the functions. Remove that line (or
the file) after the beta to turn the switch off for good.


Use your own terminal. Never paste secrets into chat, source, screenshots, logs,
command arguments, or a build define. Commands prompt for the PayMongo values:

```sh
firebase functions:secrets:set PAYMONGO_SECRET_KEY --project pantas-prod
```

Enter the PayMongo **test** secret key (`sk_test_...`), never the live key.
In PayMongo test mode, create the webhook registration for
`https://asia-southeast1-pantas-prod.cloudfunctions.net/paymongoWebhook`.
If PayMongo requires a reachable URL first, save the registration disabled until
step 6. Copy its signing secret privately, then run:

```sh
firebase functions:secrets:set PAYMONGO_WEBHOOK_SECRET --project pantas-prod
openssl rand -hex 32 | firebase functions:secrets:set TRIAL_IDENTITY_HMAC_KEY --data-file=- --project pantas-prod
```

The OpenSSL command generates the HMAC key without displaying it. Do not rerun it
on an existing deployment: rotating it changes trial identity matching. Repeat
secret setup separately for staging if needed, with staging's test webhook secret.
Do not copy secret values through the repository.

## 4. Register App Check (Aedwon-only)

Follow [L2 App Check steps](superpowers/plans/pwa-launch/evidence/l2-appcheck-r1.md),
section 4, using **pantas-prod** and the prod web app above.
Enable reCAPTCHA Enterprise, register a Website key, and allow
`app.pantas.study`, `<CONFIRMED_PROD_APP_SITE_ID>.web.app`, and
`<CONFIRMED_PROD_APP_SITE_ID>.firebaseapp.com`. Associate the key with this web
app in Firebase App Check. Copy the **public site key**, not a secret key.
Do not use debug tokens in a release build.

## 5. Build and deploy backend protections (Aedwon-only)

Use Node 22. Install dependencies and run the candidate's required checks first.
Ensure no emulator variables are set in the deployment terminal.

```sh
cd functions
npm ci
npm test
cd ..
flutter analyze
dart run tool/check_no_ai_attribution.dart
flutter test test/app/firebase_bootstrap_test.dart
firebase deploy --only firestore:rules,firestore:indexes,storage --project pantas-prod
firebase deploy --only functions --project pantas-prod
```

Wait for indexes to finish building. Stop if any deploy fails. Never relax the
rules to resolve an upload failure. `betaApplications` denies all client access,
including signed-in Pro users. The Worker writes through server credentials and
bypasses client rules. No client allow rule matches that collection.

## 6. Complete the PayMongo test webhook (Aedwon-only)

Confirm the deployed function URL matches the registration. Enable the test
webhook for `checkout_session.payment.paid` and the supported refund/dispute
notifications. Use the event names supported by the checked-in handler:
`payment.refunded`, `payment.refund.updated`, `refund.succeeded`,
`dispute.created`, and `dispute.resolved` only if available in the dashboard.
Confirm the registration's signing secret is the one set in step 3. If it changes,
set the new secret and redeploy functions before testing. Never disable signature
verification. Card and QR Ph are the current checkout methods.

## 7. Upload approved CSE content (Aedwon-only)

The uploader has no CSE filter. Use the lead-approved **CSE-only** content root,
with the same folder structure as `content/`, and its matching approved export.
Do not point this command at the full corpus. The lead must supply those two
paths and accepted content revision before this step can proceed. Do not use
`--skip-invalid` and do not regenerate a pinned protected package.
Use your own authorized Application Default Credentials, never a committed key.

```sh
node tools/upload_content/upload_content.mjs --root <APPROVED_CSE_CONTENT_ROOT> --export <APPROVED_CSE_EXPORT_JSON> --dry-run
node tools/upload_content/upload_content.mjs --root <APPROVED_CSE_CONTENT_ROOT> --export <APPROVED_CSE_EXPORT_JSON> --project pantas-prod --live
```

Confirm the dry run has no invalid sources and the expected approved CSE counts.
The upload writes server-only content paths, not `betaApplications`.

## 8. Build and publish the app (Aedwon-only)

```sh
flutter build web --release -t lib/main_prod.dart --dart-define=APP_CHECK_WEB_SITE_KEY=<PROD_PUBLIC_SITE_KEY>
node tool/web/stamp_worker_version.mjs build/web
firebase deploy --only hosting:app --project pantas-prod
```

A build without the site key compiles but refuses to start in release mode.
Do not deploy that artifact. Do not use staging's key or entry point.

Before any functions deploy, check the runtime account's roles (fails on a missing one):

```sh
ACCESS_TOKEN=$(gcloud auth print-access-token) node tool/deploy/prod_iam_preflight.mjs pantas-prod
```

After a deploy that touches sign-in, beta access or a callable, request a sign-in code at
https://app.pantas.study for an owner test address and confirm the code step opens.

## 9. Connect app.pantas.study (Aedwon-only)

In prod Firebase Hosting, select the confirmed **app site**, then Add custom domain:
`app.pantas.study`. In Cloudflare DNS, add exactly the ownership TXT and routing
records Firebase shows. Record the actual values in the deployment evidence.
Do not invent A, AAAA, CNAME, or TXT values. Use DNS-only while Firebase verifies
ownership and provisions TLS. Remove conflicting records for `app` only when
Firebase directs it. Preserve the apex `pantas.study` records and Cloudflare Worker
routes. Wait for Hosting to show Connected and a valid HTTPS certificate.

## 10. Smoke tests and enforcement (Aedwon-only)

- Open `https://app.pantas.study` in a fresh browser. Check Welcome, onboarding,
  CSE exam selection, lesson, quiz, and reload. Test phone and desktop layouts.
- Sign in, sign out, and sign in again. Confirm progress remains with the right account.
- Confirm CSE Professional and Subprofessional content loads. Check mock start,
  resume, submission, results, and the Free allowance.
- Complete a PayMongo **test** card/QR Ph checkout. Confirm the signed webhook
  grants access once. Redeliver the same event and confirm it does not extend twice.
  Check cancel and failed payment paths too. Never make a live charge for beta.
- Confirm trial eligibility and repeat-trial refusal. Check Free and Pro content
  responses from the server. Do not edit claims to bypass checks.
- Once the separate beta switch is accepted, test its server grant and expiry contract.
  Confirm the row disappears at the approved end time and progress remains.
- Confirm a client cannot get, list, create, update, or delete `betaApplications`.
  Confirm the marketing signup Worker still accepts a test application.
- Check Firebase App Check metrics for verified web requests. Follow L2 section 4:
  enforce Cloud Functions, then Firestore/Storage only after their traffic verifies.
  Confirm valid app calls work and calls without App Check fail.
- Check install/reopen on Android Chrome and iPhone Safari. Confirm privacy and terms
  links work. Check budget alerts and backend errors before inviting testers.

Record deployed commit, content revision, Hosting site, public site key identifier,
commands/results, and smoke outcomes. Never record secret values. If a smoke test
fails, stop invitations and have the lead prepare a reviewed rollback or fix.

## 11. Email sign-in code (Aedwon-only)

Web sign-in uses a six-digit email code. Two callables in `asia-southeast1` do it:
`requestSignInCode` mails the code and `verifySignInCode` checks it and returns a
custom token for the client to sign in with.

- New secret, set privately before deploying functions:
  `openssl rand -hex 32 | firebase functions:secrets:set SIGN_IN_CODE_KEY --data-file=- --project pantas-prod`.
  Never print it or commit it. Changing it invalidates any code still waiting.
- The mail reuses `GUARDIAN_MAIL_API_KEY` and `GUARDIAN_MAIL_FROM`. The Resend
  100-a-day allowance is shared with guardian email and the website.
  Sign-in codes have two daily buckets per Manila day, each logging a warning at 80%.
  `SIGN_IN_DAILY_RESERVED_CAP` (40) is only for addresses on a selected beta
  application. `SIGN_IN_DAILY_SEND_CAP` (20) is for everyone else. With the guardian cap
  of 20 the three total 80, leaving room for website mail. Raise them only after
  moving Resend off Free.
- Each IP may request 10 codes an hour, counted as a keyed hash. A school or office
  behind one address can hit this, so watch support reports.
- Verifying a code never changes an existing account. If the account is disabled or
  its email is unverified, the call returns `permission-denied` ("This account can't
  sign in. Write to support@pantas.study."). The fix for an unverified account is a
  manual support action. Verifying never upgrades an anonymous user: it signs in as
  the account that owns the address, or creates one, and the app switches to it.
- A send held back for a reason about the recipient (cooldown for someone else's
  request, the hourly limit for that address, or a full daily bucket) still returns a
  normal-looking reply. Its challenge is a stand-in with a random secret code that is
  never mailed: wrong guesses, the five-try lockout and expiry behave as for a real
  one, and even the secret code never signs anyone in. No mail goes out. Asking again
  within 60 seconds returns the same challenge and the true wait, real or stand-in,
  from a per-caller, per-mailbox entry in `signInRequests`. Watch the logs for "Sign-in code held back" (warning, with the first
  characters of the mailbox key) and for "the open bucket is full for the day" or "the
  reserved bucket is full for the day" (error, once per bucket per day).
- Plus tags are merged only for Gmail, Outlook, Hotmail, Live, iCloud, Me, Mac and
  Proton addresses (and dots for Gmail). Other domains are matched exactly.
- IAM: `createCustomToken` signs with the functions runtime service account. Grant
  that account `roles/iam.serviceAccountTokenCreator` on itself (done for
  pantas-prod on Nov 6, 2026) (it needs
  `iam.serviceAccounts.signBlob`), and confirm the IAM Service Account Credentials
  API is enabled. Without it `verifySignInCode` returns `unavailable`.
- Both callables enforce and consume App Check. The client must send a limited-use
  token on each call.
- Each request makes a challenge in `signInChallenges` with a random id that only the
  requesting user can verify. Per-mailbox limits live in `signInCodes`, and counters in
  `signInLimits` and `signInRequests`. Clients cannot read or write any of them; rules deny them.
- Optional cleanup: add Firestore TTL policies on `signInChallenges.expiresAt`, and on
  `purgeAt` for the collection groups `signInCodes`, `signInLimits` and `signInRequests`.
- Smoke test: request a code, enter it, confirm sign-in. Then enter a wrong code and
  confirm the tries count down, and confirm a second request within 60 seconds does
  not send another email.

## 12. Ship design system 4.0 (only after Aedwon says "ship it")

Aedwon decided the redesign ships during the beta, after his own staging check and his explicit
"ship it" (launch log, Nov 9). Ship the exact SHA staging served when he checked it.

- **Deploy the functions and the web app together.** The interim legal texts moved the guardian
  document versions to 2026-11-10 in the app (`lib/features/legal/domain/legal_document.dart`) and
  in the functions (`functions/src/guardianConsent.ts`). If only one side deploys, the guardian page
  refuses confirmations with "Reload the page to review the current terms." Run the IAM preflight
  (section 8), deploy functions, then hosting, back to back from the same checkout, then confirm a
  guardian confirmation works with an owner test pair.
- **Check the "Updated" date.** The three legal documents say "Updated November 10, 2026". If the
  ship happens before November 10 Manila time, change the date to the ship date (app and functions
  versions together) and rerun CI first.
- **Check out detached at the SHA and verify it** before building, as for staging:
  `git checkout --detach <sha> && test "$(git rev-parse HEAD)" = <sha>`.
- **After the deploy:** the live checks in section 8 and section 10, plus Home > Continue Lesson
  opens a lesson, Settings > Lesson Text Size shows its preview, and Settings > Accessibility >
  Keyboard Shortcuts turns letter keys off on wide screens.
- **Staging only, not prod:** the App Check debug token the lead registered on pantas-staging for
  the visual pass is deleted when the pass ends; prod never gets one.
