# CSE release lead r7: option C, launch limits, legal texts, gate-off build on staging

Written Nov 25, about 10:00 UTC (6 PM Manila) by the CSE release lead r7 (integrator). Read this instead of the r7 thread. Brief: `2026-11-25-cse-release-lead-r7-start-under18-limits-legal.md`. Policy read from main 1e718c9ed, refreshed through c6d849f31. Launch log entries for every part are on main (Nov 25, E-164, E-166, E-167, E-168).

## Current prod

- Web: build 3320840764-ac70997d11f9 (BETA_GATE=true), Hosting 13ccf513774445d7, Worker bbda6fe1-4273-4d76-bb4e-d007bc9cc341, from main bac838b00. Rollback: Hosting 23a6e25ec9bf119f, Worker d48482c8-842b-4a75-8528-ea5d410209f4.
- Functions changed today: sendguardianlink-00021-dip (switch closed; rollback sendguardianlink-00020-pey), requestsignincode-00020-mir (caps 60 and 30; rollback requestsignincode-00019-qej).
- Console changes (rollbacks in `Pantas-private/releases/2026-11-25-launch-limits/rollback.md`): cutoff $30, account budget $40, reCAPTCHA 1,000 a day, App Check token 6 h, alert "Sign-in mail above 80 a day".
- Main is ahead of prod by PR #131 (mock setup account check; no effect while gated) and docs.

## Done

1. Option C on prod (PR #129, E-164). Prod had 1 under-18 account (confirmed), 0 open requests.
2. Launch limits at 500 sign-ups (PR #130, E-166).
3. Legal texts redrafted with the business name, DPO by title and contact, option C wording; Sol High round 5 applied (E-167). PR #110 (`legal/publish-r1` 5ae67bc34, CI green, not merged) and pantas-web `legal/public-pages-r1` d09c782 (pushed). His one page: `docs/legal-drafts/2026-11-22-public-launch/change-summary.md`.
4. Gate-off build proven on staging (E-168); staging serves it now. Defect found and fixed: PR #131.

## Waiting on him (through the manager)

- Approve the legal texts (rule 5: he checks the result only).
- His Google Analytics retention and Gmail labels step; then publication: set the version stamps to the go-live day (app, functions `GUARDIAN_DOCUMENT_VERSIONS`, website), merge #110, deploy the website branch, ship the app.
- Website homepage seller details under RA 11967 Sec. 23(f) (his copy, decision D3).
- A link-preview image without the "BETA" mark (G4 row 18); its alt text follows the image.
- Optional: a dedicated DPO phone number (Sol High round 5).
- The opening day and hour, then "ship it" for the gate-off prod build (checklist G1 to G3, G6: build from main without BETA_GATE, private SELLER_* inputs loaded by the lead without printing, rollback ready, 30-minute watch).

## Lessons

- The functions predeploy guard refuses a tree behind origin/main; merge main (docs-only moves are common) before a staging or prod functions deploy.
- Ship workers never see SELLER_* values: the lead loads them from `Pantas-private/business/facts.md` with a read loop that prints only lengths, and runs the prod build itself.
- A gate-off staging proof needs a throwaway account for signed-in steps; the email code needs a mailbox.
- Process entry (Nov 25): a part report is not a stop; start the next part in the same turn.

## Branches and worktrees

Merged and removable after the usual check: `release/under18-close-r1`, `ops/launch-limits-r1`, `fix/mock-setup-account-gate-r1`. Keep: `legal/publish-r1` (worktree `legal-publish-r1`), pantas-web `legal/public-pages-r1` (worktree `pantas-web-legal`). This worktree (`qa-cse-content-fixes-r1-...`) is detached on main with generated files and the gate-off staging build in build/web.
