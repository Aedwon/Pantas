# Operations manager handoff, Nov 15, 2026

Written by the outgoing operations manager thread ("Operations Manager Role", T3 thread
`4a040e9f-6445-4d0a-8fbd-fc1c76563b12`) at Aedwon's request: "i want a fresh new operations manager
thread". Read `docs/workflow/operations-manager.md` first (takeover checklist), then this file.
Everything else is on main: AGENTS.md, WORKFLOW.md, SUBAGENTS.md, process-improvement.md, the launch log
(`docs/superpowers/decisions/2026-10-19-pwa-launch-log.md`) and the velocity log.

## State at handoff (Nov 15 ~07:00 UTC)

Aedwon's 20-item goal: 18 done, 2 date-gated. Full report: launch log, "Nov 15, Aedwon's 20-item goal:
completion report"; velocity row E-080. Prod: bite-sized lessons for all CSE subjects (CSE Algebra held),
Cloudflare serving the app, $15 billing cutoff live, App Check enforced on prod Storage.

## Active lanes (T3 threads)

| Lane | Thread id | Now |
|---|---|---|
| DS4 release candidate (integrator) | `mcp:launch:9f71e2d1c4512378a79c7379de33297f08c9261daf19e8b65e5a143b85dfde60` | Only lead that merges and deploys. Scheduler steps 3-4 due Nov 15 20:23 UTC (pinned firebase CLI only). |
| Security fixes and billing cap | `mcp:launch:eb867491ee3c4972dc9408034a2e258e9f319178ec4a4c4dbd77617bc6ccd150` | Prod App Check staged: Storage done Nov 15 06:05; Auth Nov 16; Firestore Nov 21. Tiny Firebase page after 48 h + one real Google sign-in. Prod alarms wired to cutoff Nov 21. |
| Bite-sized lessons (lead) | `mcp:launch:d8cb099cbf26808423b82a0c93177c0c119d5cc470f6304f15e8a421ea6c97fa` | Done; kept for follow-ups (CSE Algebra after the CET rewrite). |
| Beta monitor (read-only) | `mcp:launch:5571b8637093542272d0015969e732a142c5bd650e399531e5f1d6f1f1704cda` | 12-hourly passes; exit survey open until Nov 23 00:00 PHT. |
| SSOT keeper | `mcp:launch:090551797b35853669c8ebd7de5efe6916d32449b94f9aee953dc8be9dddbe59` | Daily pass. |
| Founder app spec, CET content finish | (Aedwon's lanes) | Untouched; don't drive without his word. |

## Scheduled tasks (T3)

Rebind the one-shot reminders to the new manager thread (`schedule_task` with the id and
`bindToCurrentThread: true`) so their results reach it.

| Task id (suffix) | When (UTC) | What |
|---|---|---|
| `...beta-reward-final-nov15` | Nov 15 16:15 | Final reward list (expected empty; best possible 2 of 5 days) |
| `...nudge-scheduler-steps-nov15` | Nov 15 20:35 | Backup nudge for integrator scheduler steps 3-4 |
| `...appcheck-auth-nov16` | Nov 16 06:10 | Enforce prod Auth App Check if Storage stayed clean |
| `...tiny-page-nov16` | Nov 16 19:00 | Retire old Firebase Hosting copy if a real Google sign-in is seen |
| `...appcheck-firestore-nov21` | Nov 21 06:10 | Enforce prod Firestore App Check; wire prod alarms to cutoff |
| `...alarm-price-check-dec1` | Dec 1 02:00 | Monthly cost check (alarm pricing, last month's bill) |
| `...beta-monitor-schedule-1` | every 12 h | Beta monitor pass |
| `...ssot-schedule-1` | daily | SSOT pass |

Full ids: `list_scheduled_tasks`. Prefix for the first six: `scheduled-task:command:mcp:736a8c83-0872-4bb5-a5ce-dc91db77074c:schedule-task:`.

## Standing rules from this session (Aedwon's words where quoted)

- Decisions: "for things needing my decision, consult a fable 5.2 agent instead". His still: legal
  sign-off, billing purchases, physical actions (phone tests, logins, Codex resets).
- "if it's UI, never use codex". Codex for content and non-UI work through codex-pick.
- Pace: "you can accelerate things"; Codex may run up to 3 parallel jobs (`CODEX_PICK_PARALLEL=1`,
  one per account with room); "do not mind the weekly limits. each account has 3 resets" (when a weekly
  cap blocks, tell him so he can reset; agents cannot reset). The Nov 14 two-lane cap is relaxed.
- CSE content: "majority of the CSE subjects split should be done by codex. claude should only be the
  orchestrator"; separate Codex jobs check; Claude approves after independent agreement.
- Money: "as much as possible I do not want to pay anything". $20 combined budget, alert at $10, prod
  cutoff $15 ("i will raise that limit according to the size of the userbase"). No new paid services.
- Leads may hand branches straight to the integrator; the integrator ships goal-approved work staging
  then prod and rolls back on failure.
- Deploys: pinned CLI only (`npx --prefix functions firebase ...`); after any billing relink deploy
  nothing until all functions answer (deploy guide section 13); web deploys also publish to the Worker
  (section 14). Automated browsers pass `--use-mock-keychain --password-store=basic`.
- Manager checks right after scheduled events and every 10 to 20 minutes while work is active
  ("check more often"); back every timed lead step with a durable T3 reminder.
- No computer control. Replies short, plain, no file names unless needed.

## Open items needing Aedwon (optional, no deadline)

- Legal sign-off on usage tracking step 2 notice wording and the under-18 guardian question
  (`docs/superpowers/plans/usage-telemetry/step2-legal-draft.md`; branch `web/usage-counts-r1`, flag off).
- Cloudflare token permission "Zone WAF: Edit" for the sign-in rate limit (steps in the security lead's report).
- One real Google sign-in on his phone (unblocks retiring the old Firebase copy).
- Optional: BigQuery billing export (per-item cost detail); staging Resend key (issue #74).

## Known follow-ups

- Native app release must rebuild the protected content package at schema 11.
- CET: the CET-account proof must run before any CET exam opens; the CET rewrite's baseline is the split lessons.
- CSE Algebra (1 lesson + 10 CET lessons) splits after the CET rewrite lands.
- Secret Manager versions: leave (Fable); revisit only if a real charge appears.
