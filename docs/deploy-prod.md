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

**Since Nov 17, 2026 the functions read two secrets, `PANTAS_PAYMENT_SECRETS` and `PANTAS_APP_SECRETS`, each a JSON object** (keys in
`docs/secrets-merge.md`; steps in "The merged secret" at the end of this file). The per-key
`firebase functions:secrets:set <KEY>` commands below and in step 11 are the old way: use them only
to learn which value belongs to which key, and put the value into the JSON instead.

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
- Guardian code gate (`requestGuardianCode`, `verifyGuardianCode`; under-13 accounts): uses the same
  `SIGN_IN_CODE_KEY` and mail sender, no new secret. Pending codes live in `guardianCodes`, proofs in
  `guardianCodeProofs`, per-holder daily counts in `guardianCodeLimits`; rules deny all three. Optional
  cleanup: Firestore TTL policies on `purgeAt` for those three collection groups.
- Smoke test: request a code, enter it, confirm sign-in. Then enter a wrong code and
  confirm the tries count down, and confirm a second request within 60 seconds does
  not send another email.

The existing hourly purge removes expired code and rate-limit records, including legacy counters.
Before deploying the function, deploy `firestore:indexes` and wait for the ascending indexes in
`firestore.indexes.json` to become ready. The purge uses collection-group indexes on
`limits.purgeAt`, `limits.windowStartedAt`, and `shards.purgeAfter`, plus a collection-scope
index on `webhookRateLimits.expireAt`. After rollout, confirm the hourly purge succeeds and the
legacy backlog clears before relying on the 30-day retention wording.

## 11b. Storage rules that read Firestore (once per project)

Since Nov 12, 2026, `storage.rules` checks the account-closure records in Firestore
(`firestore.exists` and `firestore.get`). Storage's service agent needs the Firestore read role
for that, or every rule that makes the check refuses the request (beta feedback attachments
failed on prod this way on Nov 12). The CLI asks to grant it only in an interactive deploy, so
grant it by hand once per project, before deploying those rules:

```sh
NUM=$(gcloud projects describe <project> --format='value(projectNumber)')
gcloud projects add-iam-policy-binding <project> \
  --member=serviceAccount:service-$NUM@gcp-sa-firebasestorage.iam.gserviceaccount.com \
  --role=roles/firebaserules.firestoreServiceAgent --condition=None
```

Granted on pantas-staging on Nov 12, 2026. Check: an owner's feedback attachment upload succeeds.

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

## 13. Billing cutoff, spend caps and relinking billing

Approved by Aedwon on Nov 14, 2026 (launch log, "security fixes and billing cap"). Goal: spend never
passes about $20 a month across both projects. Private detail (ids, exact rollback commands) is in
`~/Documents/Projects/Pantas-private/security/fixes-r1/changes-and-rollbacks.md`.

What is in place:

- **Budget email:** one $20-a-month budget on the whole billing account (prod and staging). Email at
  $10, at 100% actual and at 100% forecast.
- **Automatic cutoff:** a `billing-cutoff` Cloud Run function in each project, on the `billing-cutoff`
  Pub/Sub topic. It removes the billing account from its own project when either:
  - that project's cutoff budget passes its amount (staging $5; prod $15, which Aedwon raises as the
    user base grows), or
  - a usage alarm named `billing-cutoff: ...` opens (Hosting bytes, Storage egress, Firestore reads,
    Firestore writes, each per hour and per day). Alarms react within minutes; budget data lags hours.
  - `DRY_RUN=true` on the function means log only. Anything else but exactly `false` is also a dry run.
- **Prod alarms are notify-only until Nov 21, 2026.** On prod the eight alarms are named `usage-watch: ...`
  and only email Aedwon, so untuned thresholds cannot cut prod while baselines are collected (Fable 5.2
  ruling, Nov 14). On Nov 21, compare them with a week of prod peaks, then wire each one: rename it to
  `billing-cutoff: ...` and add a Pub/Sub notification channel for the `billing-cutoff` topic (first
  grant the project's Monitoring notification agent `roles/pubsub.publisher` on the topic; the agent
  exists once a Pub/Sub channel is created). Prod's budget cutoff ($15) is live now.
- **Spend caps:** each project pauses Cloud Run and Cloud Run functions at $5 a month (Google's spend
  cap feature). New function requests pause until the next month or a lift.
- **Bot-check cap:** reCAPTCHA assessments are limited to 300 a day per project (resets at Pacific midnight).
- **Instance caps:** 3 per function, 10 for the payment webhooks, 5 for account deletion (in code).

### When the cutoff fires

Signs: the app stops working for everyone on that project; an alarm email from Cloud Monitoring or the
100% budget email; the function log line `billing cutoff: billing DISABLED on <project>`.

1. Find out why before relinking. Check the alarm that opened (Monitoring, Alerting, Incidents) and the
   billing report. If an attack is still running, relinking restarts the bill: fix or block first.
2. Relink billing (owner account):
   `gcloud billing projects link <project> --billing-account <billing account id>` (the id is in the private file above, and in `gcloud billing accounts list`)
   Or in the console: Billing, Account management, My projects, the project's Actions menu, Change billing.
3. If a usage alarm fired, it stays open until its window passes. While it is open, nothing re-fires
   (an alarm notifies once per incident), so relinking is safe. If the cause is normal growth, raise
   the alarm threshold first, or it fires again on the next incident.
4. If the budget fired, its cost stays above the amount for the rest of the month, and every budget
   message (several a day) would cut billing again. Before relinking, raise that budget's amount, or set
   `DRY_RUN=true` on the function:
   `gcloud run services update billing-cutoff --region asia-southeast1 --project <project> --update-env-vars DRY_RUN=true`
5. Check the project works again: the app loads, a function answers (an unauthenticated call returns
   401, not 403 or 5xx), and on staging the journeys pass. Hosting, Auth, Firestore and Storage come
   back at once. Cloud Run functions return 503 "not available yet" (or 429), flipping between up and
   down, until Cloud Run resumes the project. Google documents up to 30 minutes.
   Measured on staging, Nov 14, with the $5 spend caps in place both times:
   - Cut 1: billing off 13 seconds, functions back after **34 minutes**. A functions deploy ran 2 to 6
     minutes after the relink, while Cloud Run was resuming.
   - Cut 2: billing off 11 seconds, no deploy, functions back after **5 minutes**.
   Rules while recovering:
   - **Do not deploy functions or push new revisions until every function answers.** A new revision
     does not help, and the deploy in cut 1 is the likely reason it took 34 minutes.
   - Plan for up to about 35 minutes of function outage after a relink.
   - If functions are still down 40 minutes after relinking, delete the project's two "Spend cap $5"
     budgets, wait 5 minutes, then recreate them (bodies in the private file). In cut 1 the functions
     came back 2 minutes after this, but cut 2 showed the caps do not block recovery by themselves, so
     treat it as a last resort.
   A quick check of all functions: list them with
   `gcloud run services list --project <project> --format='value(metadata.name,status.url)'` and POST
   `{"data":{}}` to each; every one should return 401 (the RevenueCat webhook returns 500 on staging).
6. If a spend cap paused functions, lift it: edit the budget and choose "Lift spend cap" (console), or
   PATCH the budget's `spendCap.inputState` to `AWAITING_NEXT_PERIOD`. It can take up to an hour.
7. Record what happened in the launch log.

### Prod: who relinks, and in what order

- Any agent session on Aedwon's Mac can relink: the owner login there has Billing Account Administrator
  on the billing account and Owner on pantas-prod (checked Nov 14 with `testIamPermissions`). If no agent
  is running, the 100% budget email or the alarm email reaches Aedwon; he can relink from the console.
- Prod order, fastest safe recovery:
  1. If it was the budget (the email says the $15 budget was passed, or the cutoff log says `cost ... over
     budget 15`): set `DRY_RUN=true` on prod's `billing-cutoff` first, or every budget message will cut
     again; then decide with Aedwon whether to raise the $15 amount before turning it back to `false`.
  2. If it was an alarm: find the cause in the incident. If an attack is still running, relinking
     restarts the bill.
  3. Relink: `gcloud billing projects link pantas-prod --billing-account <billing account id>`.
  4. Tell the integrator and the manager: no deploys until every function answers. Expect up to about 35
     minutes (staging: 34 and 5 minutes). The app pages, sign-in, the database and uploads work at once.
  5. Check all functions (list and POST, above). Then post the outage window in the launch log.


## 14. Cloudflare serves the web app (since Nov 14, 2026)

`staging.pantas.study` (since 10:34 UTC) and `app.pantas.study` (since 18:40 UTC) are served by
Cloudflare Workers (`pantas-app-staging`, `pantas-app`) from static assets, free and unlimited, instead
of Firebase Hosting, which bills every byte (security audit S-01). Code and tools:
`tool/cloudflare-app/`. Plan:
`docs/superpowers/plans/security-audit/2026-11-14-cloudflare-static-files-plan.md`.

- The Worker script runs only for `/__/*`, Firebase's sign-in pages and config, and forwards them to
  Firebase (prod: `pantas-prod.firebaseapp.com`; staging: `pantas-staging-app.web.app`). Everything else
  is a static file, with `index.html` for app routes. Headers match what Firebase sent (`headers.prod`,
  `headers.staging`).
- **Every web deploy now has two parts, and the Worker part never downloads from Firebase.** Firebase
  Hosting bills every byte it sends (rule 7; the Nov 14 mirror runs billed egress with no users). Deploy
  to Firebase Hosting as before, then publish the same local build to the Worker:
  1. `tool/cloudflare-app/deploy.sh prod|staging build/web` (wrangler login on Aedwon's Mac). It
     publishes from the local build folder only, the same files the Firebase deploy uploaded.
  2. Wait a minute: right after a Worker deploy, some files can return 404 for under a minute while
     Cloudflare's servers update. Then run
     `node tool/cloudflare-app/compare.mjs https://<host> build/web <web api key>`
     and require every path to match. It compares the Worker with the local build (status, type, body
     hash, and the cache rules in `headers.prod` or `headers.staging`) and checks the sign-in paths
     through the Worker. It fetches nothing from Firebase.
  `mirror.mjs` (copy the live Firebase release) is for emergencies only, for example a lost local
  build. It downloads about 50 MB from Firebase, which is billed. The free-tier check allows it as the
  one named exception. Do not put it in a deploy.
  A Firebase-only deploy no longer reaches users.
- **Rollback** (about a minute): detach the Worker's custom domain (Cloudflare Workers, the Worker,
  Settings, Domains; or the API), then add back the DNS-only CNAME `app.pantas.study` →
  `pantas-prod.web.app` (staging: `staging.pantas.study` → `pantas-staging-app.web.app`), TTL auto.
  Firebase still holds the full build until the tiny page below.
- **The tiny Firebase page** (closes S-01 on `pantas-prod.web.app`): only after 48 clean hours and one
  confirmed real Google sign-in on prod from the logs (Fable 5.2 ruling A). The integrator deploys it.
- **Free-plan limit:** requests that run the Worker script (`/__/*` only) count against 100,000 a day;
  above that, new sign-ins fail with 429 until midnight UTC. Static files are unaffected.

## 15. Always deploy functions with the pinned firebase-tools (Nov 14, 2026)

Use `npx --prefix functions firebase deploy --only functions --project <project>`, never the global
`firebase`. The global 15.26.0 on Aedwon's Mac reads the functions without `functions/.env.<project>`,
so env-gated exports (staging's `SCHEDULED_JOBS=off`, `WRAPPED_PAGE_PUBLIC`) come out wrong. The code
now stops such a deploy at discovery with an error naming the pinned CLI.

### Staging: delete the images after every functions deploy (Nov 15, 2026)

A functions deploy leaves container images in Artifact Registry (staging about 424 MiB; the free tier is
0.5 GB for the whole billing account). Firebase's cleanup policy runs about once a day, so same-day
deploys to both projects go over. As the last step of every staging functions deploy, run:

`tool/deploy/staging_delete_images.sh` (add `--dry-run` to list first)

It deletes every package in `pantas-staging`'s `gcf-artifacts` repository (asia-southeast1). The project
is fixed in the script and it takes no project argument. Running services keep serving, and the next
deploy builds fresh images. Prod keeps its images for one day (Fable 5.2 rule 7 ruling 4). Do not run it
while a deploy is still in progress.

### The free-tier check (rule 7)

`node tool/checks/free_tier.mjs` runs in CI (functions job). It reads the deploy config of both projects
and fails above 3 scheduled functions, any minimum instance, 6 secret versions (a dated waiver covers 16
until Nov 24, 2026), warm-up outside prod or past Nov 24, 2026 00:00 Manila, or any tool that downloads
app files from `*.web.app` or `*.firebaseapp.com`. Waivers are in `tool/checks/free_tier_waivers.json`
and their ceiling cannot rise. `node tool/checks/free_tier_live.mjs` is read-only: run it by hand or on a
schedule, weekly and after every deploy. It reads the live billing account (every project on it) and
exits 1 when any item is over its free limit.

## 16. The two secrets: `PANTAS_PAYMENT_SECRETS` and `PANTAS_APP_SECRETS` (Aedwon-only)

Why: Secret Manager bills $0.06 per active version a month after 6 free per billing account. Eight
secrets in two projects were 16 versions; two secrets per project is 4 (Fable 5.2 rule 7 ruling 1,
split on Nov 17). Keys, owners and staging notes: `docs/secrets-merge.md`. Only web checkout and
the two webhooks bind the payment secret.

Create (first time, per project). Build each JSON in your own terminal from the current values and
never print it, paste it into chat or put it in an argument. Keep the existing values of
`TRIAL_IDENTITY_HMAC_KEY` and `GUARDIAN_HMAC_KEY` exactly. Staging's payment secret holds test-mode keys only.

```sh
# payment.json and app.json are private files outside the repository, with the keys of each group.
firebase functions:secrets:set PANTAS_PAYMENT_SECRETS --data-file=payment.json --project pantas-prod
firebase functions:secrets:set PANTAS_APP_SECRETS --data-file=app.json --project pantas-prod
shred -u payment.json app.json 2>/dev/null || rm -P payment.json app.json   # then delete the files
```

Rotate one secret at a time, and destroy the old version in the same session, so the active count
never passes 5 (4 in steady state, plus at most one new version while you rotate).

1. Add a version of one secret: `firebase functions:secrets:set <SECRET> --data-file=<file> --project <project>`.
   Read the current JSON first with `gcloud secrets versions access latest --secret <SECRET> --project <project>` (do not print it; write it to a private file) and change only the key you rotate.
2. Deploy functions with the pinned firebase-tools (step 15) so every function binds the new version.
3. Verify the functions that read it (see `docs/secrets-merge.md`, Readers) and that the logs show no "Secret ... is not configured" errors.
4. Destroy the old version in the same session: `gcloud secrets versions destroy <old version> --secret <SECRET> --project <project>`. A disabled version still bills.
5. Check `gcloud secrets versions list <SECRET> --project <project>`: one ENABLED version, no DISABLED. Only then rotate the other secret.

First move off the eight old secrets: create both new secrets (4 versions across the two projects
after both projects have them; old ones are 16 until deleted, so delete them promptly), deploy,
verify, then delete each old secret (`gcloud secrets delete <KEY> --project <project>`). Deploy before
deleting: the previous release still reads them until the new one is live.
