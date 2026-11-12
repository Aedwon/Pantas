# Security and cost-abuse audit: brief

Status: Auditor 2 (Astra) running early, Nov 12 (Aedwon: "go with the reco"); Auditor 1 (Fable) and the merge are TODO. Scheduled in T3 as "Security and cost-abuse audit (Fable 5.2 High; merge Astra's early findings)".
Run: Saturday, November 14, 2026, 2:00 PM Manila (06:00 UTC). Read-only. Implements nothing.

## Why

Aedwon, Nov 11, 2026, verbatim:

> "i am very paranoid with ddos attacks, data leaks, and the like, and I don't want that to happen especially when I get paying customers and when we scale. i just watched a game developer told me he got attacked and had like 1,000 requests per second, I don't want my bills to suddenly spook me."

The question to answer first: what does a 1,000 requests per second attack cost today, per surface, and what stops it?

## Roles

- Lead (the scheduled thread): reads policy, logs the estimate, runs both audits, merges, verifies, ranks, writes the report.
- Auditor 1: Claude Fable 5.2 at high effort (T3 `delegate_task`, model `claude-fable-5-2`, effort high).
- Auditor 2: Codex GPT 6 Astra at high effort, only through `codex-pick`, never bare `codex`. It runs early, from Nov 12 (velocity E-038), so it uses Codex's separate reset cycle. Its output is in `~/Documents/Projects/Pantas-private/security/`: `2026-11-12-codex-astra-audit.md` and `2026-11-12-auditor2-findings.md`. On Saturday the lead reruns Astra only for sections without a progress line. Run with no stdin (the first Astra runs on Nov 7 stalled waiting on stdin). If every account is full (exit 75), report the reset time and continue with Fable alone. Do not substitute another tool.
- The two audits are independent: same scope, neither sees the other's findings.
- Codex writes as it discovers, never only at the end (Aedwon, Nov 11: "for Astra things, have it write as it discovers, not at the end, so that when its turn reaches its limits, it doesn't just waste that tokens for nothing"). Run Astra in its own worktree; its brief tells it to append each finding to `auditor2-findings.md` in that worktree the moment it is verified (one block per finding, in the deliverable's format), and to append a one-line progress note after each scope section (A to D), so a usage-limit stop keeps everything found so far. The lead copies that file to `~/Documents/Projects/Pantas-private/security/` and never commits it. If the run stops, the next run reads the file and continues from the last finished section instead of starting over. Run Astra alone: `codex-pick` refuses a second concurrent run.

## Rules for the run

- Start: fetch origin; read `AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md` from `origin/main`; log an estimate row in `docs/superpowers/estimates/velocity-log.md` first and actuals at the end.
- Read-only. No code, rule, config, IAM or billing change. No load test or attack traffic against prod or staging. No secret printed or written anywhere (read secret names and IAM, never values).
- Read-only cloud checks are allowed (Cloud Billing API, IAM policy reads, Cloud Logging reads, App Check config reads, Cloudflare dashboard reads through the existing DNS-only token scope where it applies). If a check needs a write or a user's own console login, list it as "needs Aedwon" with numbered steps.
- Verify every finding in code or config yourself. Drop what you cannot confirm. Mark each item verified, unverified or needs-console.
- Cost figures: use current published prices fetched at run time, cite the source and date. Never invent a figure.

## Where the code is (read this first)

`origin/main` carries policy and docs, and an older `functions/`. The shipped backend is on `web/design-system-4` at `17c8b5710` (deployed to pantas-prod on Nov 11, 2026). Audit that revision for source, and the live projects for config. Re-check the head before starting.

Projects: `pantas-prod` (app.pantas.study), `pantas-staging` (staging.pantas.study), region `asia-southeast1`. Billing account `01E18B-95B3AF-A43FD4` covers both. Site and DNS: pantas.study on Cloudflare (a `pantas-web` Cloudflare Worker serves the marketing site and writes beta signups to `betaApplications`). Hosting is Firebase Hosting, targets `site` and `app` in `firebase.json`.

## Scope

### A. Cost abuse and DDoS

For each public surface, estimate the cost of 1,000 requests per second sustained for 1 hour and for 24 hours, what stops it, and the worst case if the stop fails.

Surfaces and starting points:

- Hosting (`firebase.json`): hashed assets are `immutable`, but `index.html`, `/flutter_service_worker.js`, `/manifest.json`, `/version.json`, `/*.js` and `/` use `max-age=0, s-maxage=31536000`. Check whether the CDN actually serves these from cache under load or revalidates to origin. Check Hosting egress ($0.15/GB past the free tier per the launch log) against the app bundle size. Check the `/wrapped/**` rewrite to `renderWrappedPage` (HTTP function, unauthenticated by design; look for caching and per-IP limits).
- Callable functions: every callable in `functions/src/*.ts` (about 40; list them from `index.ts`). For each: `enforceAppCheck` (from `_appCheck.ts`, true outside the emulator), `consumeAppCheckToken` (replay protection) only on some, auth required or anonymous allowed, and which rate limit applies.
- HTTP functions: `paymongoWebhook.ts`, `revenuecatWebhook.ts`, `renderWrappedPage.ts`. They cannot use App Check. Check cheap early rejection before any Firestore read, signature check cost, and `WEBHOOK_MAX_INSTANCES`.
- Instance caps and concurrency: `functions/src/_options.ts` sets a global `maxInstances` of 10 (`DEFAULT_MAX_INSTANCES`), 30 for webhooks, 20 for account deletion. The file notes 1 vCPU and concurrency 80 at 256 MiB, so up to 800 concurrent requests per function. Verify against the deployed Cloud Run revisions (not just the source). Compute the maximum cost of a saturated function across all functions at once.
- Warm instances: `functions/src/keepWarm.ts` (`keepCallablesWarm`, every 5 minutes, gated by `WARMUP_ENABLED`, default false; 11 targets). Check what is set on prod, the monthly cost, and whether any function sets `minInstances`.
- Per-user and per-IP limits: `functions/src/_limits.ts` (`allowAtMost`, `takeAtMost`, counters at `users/{uid}/limits/{key}`) is used by about 19 functions; `betaReward.ts` has its own `guard()` (feedback 40 a day, day 20, status 120 per 10 minutes, survey 20, activate 20). `guardianConsent.ts` and `signInCode.ts` limit by hash. Questions: Is any limit keyed only by uid, so a script that creates new anonymous accounts bypasses it? Is there any per-IP limit? Does every limit check itself cost a Firestore read and write (a transaction per request multiplies cost under attack)? Which callables have no limit?
- Anonymous sign-in: unlimited account creation is the main amplifier. Check Auth quotas, `onUserCreated.ts`, `cleanupOrphanAnons.ts`, and whether App Check is the only gate on anonymous sign-up. Check that Identity Platform sign-up and sign-in quotas are set.
- Sign-in email and SMS: `signInCode.ts` (`requestSignInCode`, `verifySignInCode`) sends mail through the guardian mail key. Check per-address, per-IP and global send caps, Resend plan limits and cost, and whether mail can be sent to arbitrary addresses (spam relay, sender reputation, bill). Check whether any SMS or phone auth is enabled (should be none).
- Guardian mail: `guardianConsent.ts` (`sendGuardianLink`, `answerGuardianRequest`) and `guardianMail.ts` (Resend). Check caps per child, per guardian address, per day, and global. Check that the link cannot be used to mail a victim repeatedly.
- PayMongo: `paymongoCheckout.ts` (callable creates a Checkout Session; each call hits PayMongo's API), `paymongoWebhook.ts`. Check per-user limits on checkout creation and any cost or rate limit on PayMongo's side.
- Firestore: reads and writes per request on the hot paths (`content.ts`, `ingestSession.ts`, `roadmap.ts`, `mock.ts`, `studyInsights.ts`, `webEntitlement.ts`). Look for unbounded queries, missing `limit()`, collection scans, fan-out writes, and sync rows (`sync_generations/**` rules allow client writes by Pro owners; check document size and count caps). Content ceiling: `_contentCeiling.ts` (200,000 delivered per day, 50 shards, env override `DAILY_CONTENT_CEILING`); per-user 300 and 200 a day and 1000-a-day request cap (Aedwon, Nov 2). Verify they hold.
- Storage: uploads to `betaFeedback/{uid}/{feedbackId}/{index}` (max 5 MiB, png, jpeg or webp, 3 images per report) and `wrapped/{uid}/{hash}.png` (max 5 MiB). Rules allow any signed-in user, including anonymous. Check the number of uploads per user (unbounded?), total storage growth, App Check enforcement on Storage and Firestore (the `OPERATIONS.md` checklist item "validate App Check enforcement for Firestore" may still be open), egress, and lifecycle rules. `purgeOldExports.ts` and `cleanupWrappedOrphans.ts` handle cleanup.
- Beta feedback: callable `betaReward.ts` plus Firestore `users/{uid}/betaFeedback`. Check the 40 a day limit against storage and read cost.
- App Check: reCAPTCHA Enterprise on web (site key in `tool/deploy/staging_web.sh`), Play Integrity on Android. Check enforcement per product in the console (Firestore, Storage, Auth, Functions), token TTL, any debug tokens left registered (a debug token was created and deleted on staging on Nov 9; confirm none remain on prod), and reCAPTCHA Enterprise assessment pricing at volume (it is billed per assessment past a free tier; 1,000 requests per second through the App Check exchange could itself be a bill).
- Budgets and caps: Oct 31 launch-log entry says a $5 monthly budget alert on each project (50, 90, 100%) and `docs/OPERATIONS.md` says $10. Reconcile. A budget alert caps nothing and has hours of delay. Evaluate: a Pub/Sub budget notification that auto-disables billing (or sets function `maxInstances` to 0) on prod and staging; API quota caps (Firestore, Functions, Identity Platform, reCAPTCHA); Cloud Run per-service limits. State the worst case money lost before a human reacts, and what disabling billing does to a paying customer.
- Edge: is anything in front of `app.pantas.study` and the Cloud Function URLs? Cloudflare is the DNS provider for pantas.study. Check whether records are DNS-only or proxied, and what proxying through Cloudflare (free plan rate limiting, WAF, bot fight mode) would break (Firebase Hosting certificate provisioning, App Check, caching headers). Function URLs under `cloudfunctions.net` bypass any edge in front of the site; check whether they can be fronted (custom domain, Cloud Armor with a load balancer, API Gateway) and at what monthly cost. Give a recommendation with a price.
- Staging: `pantas-staging` is live at staging.pantas.study with test accounts. Check that it has the same caps and App Check, is not indexable, and cannot be used to run up the shared billing account.

### B. Data leaks

- Firestore rules (`firestore.rules`) and Storage rules (`storage.rules`) for every path. Test the rule logic by reading and by emulator rules tests that already exist; do not touch prod data. Special attention: minors and guardian data (`guardianTokens`, `guardianConsentEvidence`, `guardianLimits`, guardian emails, age and birth year fields on `users/{uid}`), payments (`paymongoPayments`, `users/{uid}/passes`, `grants`), beta feedback images and text, `betaApplications` (written by the Cloudflare Worker with server credentials), Wrapped share cards (public by design; check what they expose), `publicIds`.
- The `users/{uid}` update rule (`isOwner` update) and field allow-lists: can a client write `pro`, entitlement, age or consent fields?
- IAM and service accounts: roles on the Firebase Admin SDK, Cloud Functions runtime, App Engine and Compute default service accounts, Cloud Build and deploy accounts (`tool/deploy/prod_iam_preflight.mjs` encodes the expected set), who has Owner or Editor, API keys and their restrictions (browser keys must be restricted by referrer and API), Secret Manager access.
- Secrets in the public repo: scan the full history of all branches (the repo is public) with gitleaks and manual greps for service account JSON, `sk_live_`, `sk_test_`, PayMongo and RevenueCat keys, Resend keys, Cloudflare tokens, signing keys, reCAPTCHA secret, `.env` files. The gitleaks job flagged the public App Check site key once; that key is public by design. Confirm which hits are public by design and which are not.
- Public CI logs and artifacts: the repo is public, so Actions logs and artifacts are public. Check every workflow for echoed secrets or env, uploaded artifacts that contain config or test data (`app-dev-debug` APK, journey screenshots and traces), and `pull_request_target` or fork-PR exposure of secrets.
- Telemetry and logs: `clientTelemetry.ts` (`reportClientTelemetry`), `_audit.ts`, `recordSignInEvent.ts`, `ingestSession.ts`, Cloud Logging content. Look for personal data, IP addresses, email addresses, names, birth years, guardian emails in logs, audit rows, or telemetry. Check log retention and who can read logs. Cross-check against `docs/PRIVACY.md` and the teen notice draft in `docs/legal/drafts/2026-11-05-teen-notice-and-terms-web.md`.
- Backups and exports: `exportData.ts` (exports to `exports/{uid}/`, rules deny all client access; check signed-URL or download path, expiry, `purgeOldExports.ts`), Firestore backups, PITR, scheduled exports, bucket ACLs and public access prevention, bucket IAM, Cloud Storage default bucket CORS.
- Admin and founder paths: `_admin.ts`, `grants.ts`, `betaPro.ts` (`setBetaPro`), `publicIdAdmin.ts`, founder app work (`docs/superpowers/decisions/2026-11-02-founder-app-log.md`). How is admin identified (custom claim, UID list, email)? Can a user obtain it? Is it logged?
- Third-party keys in the client: Firebase web config, reCAPTCHA site key, RevenueCat public SDK key, PayMongo public key, Sanity project id and token (check that no write token is in the bundle), Google OAuth client ids. Inspect the built web bundle on prod (a plain HTTP fetch of the public JS is allowed) for anything that is not a public key.
- The Cloudflare `pantas-web` Worker: its secrets, who can deploy it, and the DNS token saved at `~/.config/pantas/cloudflare.env` (DNS Write on pantas.study only; check its scope and expiry; never print it).

### C. Auth and payments integrity

- Sign-in flows: Google (`googleSignIn.ts`, `exchangeGoogleSignIn`), email codes (`signInCode.ts`), anonymous, and linking and merging of anonymous accounts. Earlier audits on Nov 7 (see `docs/superpowers/decisions/2026-10-19-pwa-launch-log.md`, "Sign-in exchange audit") found no takeover path or App Check bypass; re-verify on the shipped revision and look at code-guessing limits, code entropy and expiry, replay, email enumeration, and account-linking takeover.
- Custom claims and entitlement checks: `_pro.ts`, `revenuecatClaims.ts`, `entitlementInputs.ts`, `webEntitlement.ts`, `betaAccess.ts`, the `pro` claim read in `firestore.rules` (`isProOwner`, `isProUser`, `request.auth.token.pro`). Check claim staleness after refunds or expiry, who can set claims, whether paid content (`contentPro`, `examTracks/*/proContent`, `getProContent`) can be reached by a Free user, and the Pro grant paths (`grants.ts`, `paymongoGrants.ts`, beta Pro, gift codes).
- Webhooks: `paymongoWebhook.ts` and `paymongoPolicy.ts` (signature verification with `PAYMONGO_WEBHOOK_SECRET`, timestamp tolerance, test versus live mode mismatch, replay and event-id de-duplication, amount and product checks, refund path), `revenuecatWebhook.ts` (authorization header check, constant-time compare, replay). Check that a forged or replayed event cannot grant Pro. The prod test webhook and the staging webhook must not both be live (Nov 9 note).
- Payment amounts and products: `products.json`, `paymongoCheckout.ts`. Check the client cannot choose the price, tier or duration, and that tiers match `docs/pricing.md`.
- Live-mode readiness: PayMongo stays in test mode until the BIR COR, DTI name and PayMongo upgrade are done (`docs/superpowers/plans/2026-11-10-manager-handoff.md`). Audit as if live, and list what must be true before keys change.

### D. Supply chain

- Dependency advisories: run osv-scanner on `pubspec.lock`, `functions/package-lock.json` and any other lockfile (the CI `osv` job, `google/osv-scanner-action` v2.7.0, reports non-blocking; branch `deps/functions-osv-fixes` exists; see `docs/superpowers/2026-08-11-dependency-audit.md`). List reachable, exploitable advisories only, with fix versions.
- GitHub Actions: `.github/workflows/ci.yml`, `main.yml`, `browser-journeys.yml`, `.github/actions/setup-app/action.yml`. Check `permissions:` (least privilege, default token read-only), actions pinned to a commit SHA versus tags (`actions/checkout@v4`, `subosito/flutter-action@v2`, `gitleaks/gitleaks-action@v2`, `returntocorp/semgrep-action@v1`), third-party actions with secrets, triggers on forks, and whether any workflow holds deploy credentials. Check branch protection on `main`, who can push, and the repo's Actions settings for fork PRs.
- Deploy path: `tool/deploy/staging_web.sh`, `docs/deploy-prod.md` (on the code branch), who holds deploy credentials, and where they live.
- npm and pub install scripts, `pubspec.lock` hosted sources, any git-sourced or path dependencies.

## Deliverables (as the scheduled task states)

1. Verified, ranked findings. Rank by severity and by money at risk. For each: what, where (path and config), how verified, severity, money at risk (with the arithmetic), the fix, the cost of the fix (work and money), and a recommendation.
2. A plain-language table of "1,000 requests per second for 1 hour and 24 hours: cost today" per surface, and after the recommended fixes.
3. Report at `docs/superpowers/plans/security-audit/2026-11-14-report.md` on main (`[skip ci]`, no AI trailers).
4. Anything that would reveal an exploitable, unfixed weakness in this public repo goes only in `~/Documents/Projects/Pantas-private/security/`. The public report carries a one-line pointer per item and no detail.
5. A plain-language summary for Aedwon, under 200 words: top risks, what a 1,000 requests per second attack would cost today, and the fixes to approve. Follow the writing rules in `WORKFLOW.md`.
6. A launch-log entry in `docs/superpowers/decisions/2026-10-19-pwa-launch-log.md`.
7. Implement nothing. Fixes wait for Aedwon's approval of the plain-language summary and a complexity choice (minimal, balanced or hardened) for each.

## Open facts the lead should resolve first

- Is the budget $5 or $10, and are the alerts wired to anything beyond email?
- Is `WARMUP_ENABLED` true on prod, and what does the warm list cost per month?
- Are Firestore, Storage, Auth and Functions App Check enforcement on in the prod console?
- Are the Cloudflare records for `app.pantas.study` proxied or DNS-only?
- Deployed `maxInstances`, `concurrency` and `minInstances` per function on prod, from Cloud Run, against `_options.ts`.
