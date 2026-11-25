# Operations manager handoff (Nov 26, 1:35 AM Manila)

Old manager thread: `mcp:launch:2f628e2495c6e1411884e3ca9e4a1bdc13467273ae2643e58f0fdb984177a926` (retire it after takeover). Read first, from main: AGENTS.md, WORKFLOW.md, `docs/workflow/operations-manager.md` (lanes table current as of Nov 25 8 AM; update it), `docs/workflow/process-improvement.md` (ten new Nov 25 entries: exact words in briefs, answered items stay off his boards, rulings name their search, patterns.md checked in reviews, internal terms scan, stacked buttons, lesson depth), and the "Aedwon's requests" table at the top of `docs/superpowers/backlog.md` (his running list; keep it current). Previous note: `2026-11-25-operations-manager-evening.md`.

## Right now (1:35 AM)
- He is checking his inbox for a Google Cloud email "Payment follow-up created (owner action)" from the security lead's second staging alert test (sent 1:21 AM). The first test at 1:10 AM did not reach him ("nope no email from gcloud"). Relay his yes/no to the security lead. If no, the lead sends a direct test notification to the channel.
- PayMongo dashboard was under maintenance at 1:17 AM, so the live key is deferred. A bound one-shot schedule at 9:00 AM Manila (Nov 26) checks PayMongo, then asks him for the live key through request_secret (delivery "file") and runs `live_cutover.mjs` (dry run && --apply in ONE command; script in `~/Documents/Projects/Pantas-private/releases/2026-11-26-money-path-prod/`). Then the security lead deploys the functions and does one real small payment with him. The alert email must be confirmed first.

## Decisions he made Nov 25 (all in the launch log, verbatim)
Legal texts approved ("legal is fully approved"); ₱1,000 liability floor kept; invoices are his hand-written BIR invoices (photo to buyer); trial codes 2 years; GA4 at 2 months, Gmail labels done; homepage seller line approved; opening "when ready"; guided first run approved ("okay lgtm!"), built before launch; payments un-paused; Nov 14 "no new worker" rule lifted for the service worker fix only; support channel support@ shown in Settings; lesson walk-through standard approved (picks at recommendations), queued for CSE; pentest not now (manager default, he said "idk"); under-18 sign-up closed (live).

## Leads (three active; above the 2-lead cap; he was told and did not object; overload at 12:15 AM handled)
- CSE release lead r8, integrator `mcp:launch:55d23bdfde1cbdbac9638f0f42400f367a941a688ddb9d6bea85cda3646e2cd2`: P10 and P7 merged and on staging; service worker fix (option 1, Codex audit 1 running); then P12 loop runs; merges payment PRs; then the opening ship (gate-off, legal pages with go-live stamps, website pages and seller line, link-preview image, checkout opens). Tells the manager the hour first.
- UX lead `mcp:d8548b12-d7ea-4fd6-8dc3-919a8b8c0570`: building the approved guided first run (board https://claude.ai/artifact/D3JLTrRGiN8vjnfLrbhoMN) plus the support@ Settings row; checks on hosted CI. It tends to end turns without a watcher: nudge if silent.
- Security and billing lead r2 `mcp:launch:e29d46394b524c9bb1b3efca97421eeae55d54872d03697127a873b07e99ebc5`: payment fixes merged (#109, #136, #91), QR Ph only; alert email test; live key in the morning. Handoff PR #140.
- Parked: lesson walk-through lead `mcp:launch:6fcf82ba3dd0d64d320c20b9d5b7dff27f1315495e1704252607c246f86f05dd` (approved; start when a lead slot frees).
- Paused by him: under-13 (keep 13 to 17 closed), PSHS-NCE (go/no-go Dec 8: raise around Dec 1), QG Phase 2, dots.
- Every Flutter run goes through `/Users/aedwon/.t3/worktrees/Pantas/qa-cse-release-r1-485b9ecb7345be22/build/audit/flutter-locked.sh`; full suites on hosted CI.

## Still his
Live PayMongo key (morning), the alert email check, NPC and LGU, Codex accounts a and c re-login (401), "Did you pass?" outcome counts (option A, Fable advice; must ship before Mar 14, 2027), the no-echo loader for seller inputs (asked; he asked a clarifying question, answered, no yes yet).

## Schedules (all bound to the old manager thread: rebind each to the new thread with schedule_task, scheduledTaskId, bindToCurrentThread true)
Heartbeat every 55 min (prompt current), daily sweep 1:00 AM, housekeeping 4:00 AM (15 GB floor), PayMongo retry Nov 26 9:00 AM, DMARC Nov 28 10:00 AM, Dec 1 cost check. List with list_scheduled_tasks.
