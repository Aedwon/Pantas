# New design restart: status

The single resume point for the engineering restart. Any fresh session resumes from this file
alone. Every step ends by updating this file and pushing it to main.

Controlling documents:
- Strategy (plan of plans): `docs/superpowers/2026-10-05-engineering-restart-strategy.md`
- Decision record: `docs/superpowers/decisions/2026-10-05-engineering-restart-log.md`
- Integration branch: `integration/new-design-r1` (worktree `../Pantas-wt-integration-new-design-r1`)

## Lock

State: free
Holder: none
Since: 2026-10-06 (released at the level 4 stop)

Rule: a run takes the lock by setting State to held with its start time, then pushes. If the lock
is held and younger than 2 hours, a run exits. A lock older than 2 hours is stale and may be
taken. Release it by setting State to free when the step ends.

## Current stage

Level 3 (strategy B5). Level 2 gate passed October 6, 2026.

## Waiting on Aedwon

Nothing.

## Next step

Waiting on Aedwon (level 4 start). Level 4 begins with W0 once he answers:
1. Permission to use the signing seed (optional W0 package; required for the W5 release package).
2. Play Console and RevenueCat: the four Civil Service products, trial moved to Monthly ("new
   customers only, across all subscriptions"), price points confirmed (W3 P2).
3. RevenueCat secret API key stored as Functions secret `REVENUECAT_SECRET_API_KEY` (W3 P1).
4. Exam dates with source links (W3 P3; W0 catalog).
5. Whether App Store purchases are in beta scope (W5 Task 6).
6. Privacy policy sentences for the Pantas ID (lead drafts in W3 Task 10).
7. Season Pass bought by an active Student subscriber: confirm the lead default and copy (W3 Task 6).
8. Approval to upload lesson illustrations to Sanity so `assets.json` exists; until then no lesson
   image ships (W0 Task 4b).
9. Approval to force-push main to remove the AI attribution trailer from b43d93a6 (or leave it).
Deploys (functions, rules) are asked separately when each is ready (W3 P4).

## Steps

| Step | State | Commit or note |
|---|---|---|
| Strategy Part A approved | done | approval in the decision record |
| B3.6 SSOT baseline line | done | Google Doc tab "Pantas Production Readiness Assessment", 5 Oct entry |
| B9 status file | done | this file |
| B9 resume task | paused by Aedwon Oct 6 | work continues in the interactive session |
| B3.1 gap pass | done | raw lists in stage0/ |
| B3.2 kept-work triage | done | stage0/triage.md |
| Stage 0 decisions to Aedwon | answered | answers in the decision record |
| Kept-work cleanup | done | archive/pre-restart-kept-work at 2bdde4fd |
| B3.3 spec update | approved | specs/2026-10-05-new-design-amendment-design.md |
| B3.4a traceability: boards, decisions, stage 0 items | done | a9d94795 |
| B3.4b traceability: gap pass section B rows | done | 215 rows; none needed a new product decision |
| Stage 0 exit | done | all B3 steps done; every input item has a workstream |
| B3.5 execution arrangement | done | recorded in the decision record |
| Level 2 plans (B4) | done | 13 plans; traceability level 2 column filled |
| Level 2 gate review | passed (review 5) | gates/l2-gate-review-5.md |
| Level 3 plans (B5) | done (13 plans, parallel map); traceability level 3 column filled | L3-*.md, L3-parallel-map.md |
| Level 3 gate review | passed (review 5) | gates/l3-gate-review-5.md |
| Stop before level 4, notify Aedwon | done (Oct 6) | waiting on his level 4 start answers |

## Last completed step

Level 3 gate passed (review 5, Oct 6). Stopped before level 4.
