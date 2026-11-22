# M4 security pass before live keys (plan)

Owner: security and billing lead (r2). Branch `web/security-m4-r1` from main. Velocity E-136.
Policy main ac270d1aa. Checklist gate M4 in `docs/superpowers/plans/2026-11-22-cse-public-release-checklist.md`.

Manager, verbatim (Nov 22): "Start M4, the security pass before live PayMongo keys, as you planned it:
about 5 narrower service accounts, the Worker security headers (report-only first, for a week), and Pro sync
quotas. Codex weekly room is spent until Aedwon's reset, so do the Codex money-path audit right after it;
leave a ready-to-run command and brief." Then, on the corrected sync estimate: "A and B. ... Order: A first
(staging, then ready for his ship-it), then the service accounts and headers, then B. B needs the Flutter
slot for its build. Ask me when you reach that step".

Caps: one Sonnet worker at a time (briefed to start no subagents); no Flutter command without the
manager's slot; rule 7 pre-run count before every staging run; prod only on Aedwon's "ship it".

## Order and parts

1. **A. Sync row fields typed and sized (rules only).** Source finding: S-15 (private merged report,
   Nov 14): "the row validator bounds metadata only; payload fields are untyped and only the 1 MiB document
   limit applies". For each of the 11 synced row types in `firestore.rules`, every payload field gets the
   type the app's mapper writes (`lib/core/sync/mapping/*.dart`), nullable where the mapper can write
   null, with size caps on strings (ids and names short, JSON fields bounded with margin above the largest
   real value), numeric fields numbers, booleans bools, dates in the exact form the mapper writes. Row ids
   bounded and free of `/`. No app change: every write the current app makes must still pass.
   Tests: rules emulator tests that a row from each mapper (built by the app's own serializer output shape)
   passes, and that a wrong type, an oversize string and an unknown field each fail. Staging deploy of
   rules only, then a Pro sync proof on staging (pre-run count first).
2. **Service accounts (S-13, "Service account privilege", 0.5 to 1 day).** Today every function runs as
   the default compute account, which holds project Editor. Replace with about five accounts by need,
   from the inventory (`scratchpad/sa-inventory.md`, worker report): set a default in `_options.ts`
   (`serviceAccount: '<name>@'`, which the pinned CLI expands per project) and override per function.
   Each account gets only its roles; secrets accessor on named secrets only; token creator only on the
   account that mints custom tokens. The IAM preflight checks the new accounts. Staging first; the default
   compute account keeps Editor until prod has run a clean day on the new accounts, then Editor is removed
   (a separate, logged step).
3. **Worker security headers (done on the branch, dc486121f).** Enforced: nosniff, Referrer-Policy,
   Permissions-Policy, `frame-ancestors 'self'`; a report-only CSP with the inline script's hash, reporting
   to `/__/csp-report` (logs origin and path only, Workers Logs Free: 200,000 events a day, 3-day
   retention; Cloudflare's Observability pricing changes Dec 1, 2026, check then). One week of reports,
   then the enforcing ship with any needed sources added.
4. **B. Per-account sync write quotas and a server-owned entitlement version (about 3 days; app code and a
   Flutter build).** A counter document updated in the same batch as each sync write, checked in rules
   with `getAfter`, caps rows and bytes per account per day; rules read a server-written entitlement
   version so a refund ends sync at once instead of after a token lifetime. Needs the Flutter slot; the
   lead asks the manager before that step.
5. **Codex money-path audit, after Aedwon's Codex reset.** Brief and command ready at
   `docs/superpowers/plans/2026-11-22-m4-money-path-audit.brief.md` (two read-only GPT 6.2 Sol High
   runs; findings appended as found).

## Free-tier count (rule 7)

Service accounts, rules and headers: no cost. Workers Logs: free within 200,000 events a day. Each staging
proof is counted before it runs and logged with its actual use.

## Standards applied

`~/Documents/Projects/agent-standards/server-caching.md` does not apply. Security headers follow the
OWASP Secure Headers Project and MDN's CSP guidance (report-only before enforcement); least privilege for
service accounts follows Google Cloud IAM's "use service accounts with minimal permissions" guidance. No
sheet exists yet for application security; one is to be written before part B's spec.

## Staging proof, service accounts and headers: pre-run count (rule 7, written before the run, Nov 22)

Already used on pantas-staging this quota day (since Nov 22 08:00 UTC): 0 reads, 0 writes. Budget: 40,000
reads, 16,000 writes, 288 MB egress.

| Step | Reads | Writes | Egress |
|---|---|---|---|
| Functions deploy with the five accounts, image cleanup | 0 | 0 | 0 |
| Calls as a throwaway account with a short-lived debug token, one per account: mock setup (app), web entitlement (entitlements), web plans (identity, reads the app secret), a RevenueCat webhook with a wrong key (payments, reads the payment secret) | up to 300 | up to 40 | 0 |
| Worker files mirrored from Firebase Hosting for the headers deploy (about 40 MB from pantas-staging-app.web.app) | 0 | 0 | about 40 MB |
| Headless page load of staging.pantas.study to collect CSP reports and check headers | up to 300 | up to 20 | about 10 MB (served by Cloudflare, not Firebase) |
| Total, with 50% margin | **about 900** | **about 90** | **about 75 MB** |

Expected day total: well under every budget. Go.

## Staging proof results (Nov 22, 11:00 to 11:20 UTC)

- Part A: firestore.rules released on staging (compiled). Staging has no sync rows; all 79 real-app rows from
  prod pass the new rules in a local emulator replay (data deleted after). Rules tests 140/140.
- Part 2: `function_service_accounts.sh pantas-staging` applied (rerun is a no-op). The first deploy stopped
  with HTTP 400 before changing anything: the pinned CLI expands `name@` when it deploys but not when it grants
  secret access; accounts are now written in full (test fails on the short form). Second deploy: 56 updated;
  services by account: pantas-app 32, pantas-identity 14, pantas-entitlements 5, pantas-payments 3, pantas-jobs 2
  (scheduled jobs are off on staging), none on the default compute account. Preflight OK.
- Live calls as a throwaway account with a short-lived debug token (both deleted): getMockAvailability with
  setup 200 (155 questions); getWebEntitlement 200; listWebPlans 200 (reads the app secret); paymongoWebhook with
  a bad signature 401 (reads the payment secret). revenuecatWebhook 500 is staging's missing RevenueCat
  configuration, the same answer as before the change. No permission errors in staging logs since the deploy.
- Policy Troubleshooter (enabled on staging; free): pantas-identity CAN signBlob on itself; pantas-jobs CAN invoke
  Cloud Run and receive Eventarc events; pantas-identity CAN delete Auth users; pantas-payments CAN read the payment
  secret. pantas-app CANNOT signBlob, delete users, read the payment secret, or set project IAM.
- Not proven live: custom-token minting (needs a real email or Google sign-in) and the three scheduled jobs (off on
  staging). Both are checked on prod right after the ship, with rollback ready.
- Headers: need a local web build to deploy (the Firebase mirror is emergency-only, rule 7 ruling 2), so they
  wait for the Flutter slot.
- Staging use this quota day: under 1,000 reads (pre-run count about 900).

## Prod ship steps (on Aedwon's "ship it")

1. Part A: `firebase deploy --only firestore:rules --project pantas-prod` (pinned CLI); watch Pro sync for 24 h.
   Rollback: release main's rules.
2. Part 2: `tool/deploy/function_service_accounts.sh pantas-prod`, then the IAM preflight, then the functions
   deploy (pinned CLI). Right after: one email sign-in (custom token), the next scheduled run of each of the 3
   jobs, and the error log. Rollback: redeploy functions from main (the default compute account keeps Editor
   until a clean day passes; removing it is a separate logged step).

## Headers on staging (Nov 22, about 11:40 UTC)

- No Flutter build: the staging Worker was redeployed with the exact 84 files it already served, listed from
  the live Firebase release (metadata only) and downloaded from the Worker itself (Cloudflare, no billed
  egress). Staging's app build is unchanged (2354145730-76cfbf733ec9). `compare.mjs`: 92 of 92 match,
  headers included. `/__/csp-report` answers 204.
- Headless Chromium load (mock keychain, closed after): the app boots, no page errors. First load reported 5
  sources; the four real ones (Cloudflare's analytics beacon, fonts.gstatic.com, Google Identity Services,
  Google's analytics tag) are now allowed. Still reported: inline scripts created at run time by
  `main.dart.js` (9 distinct hashes on one load), so hashing them one by one will not hold. Reports reach
  Workers Logs as compact lines (origin and path only).
- Decision before enforcing (after the prod week): how to allow the app's run-time inline scripts (for example
  `'strict-dynamic'` or `'unsafe-inline'` for script elements only), from the week's reports.
- Prod ship: the same method with the files `app.pantas.study` serves, then `compare.mjs`; rollback is a
  redeploy of the previous Worker version (`wrangler rollback`).
