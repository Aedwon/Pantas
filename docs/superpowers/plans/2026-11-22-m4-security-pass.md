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
