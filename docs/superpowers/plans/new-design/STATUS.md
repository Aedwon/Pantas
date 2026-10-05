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
Since: none

Rule: a run takes the lock by setting State to held with its start time, then pushes. If the lock
is held and younger than 3 hours, a run exits. A lock older than 3 hours is stale and may be
taken. Release it by setting State to free when the step ends.

## Current stage

Stage 0 (strategy B3).

## Waiting on Aedwon

Yes: approval of Part A of `docs/superpowers/specs/2026-10-05-new-design-amendment-design.md`,
including its three questions (notification overlap, countdown when the daily reminder is off,
follow-up time range). Preview: `docs/design/proposals/reminders-2026-10-05.html`,
https://claude.ai/artifact/JAB6x4kqc8fKyyAhoAr6NV. Sent October 5, 2026.

## Next step

After approval: record his exact words, apply his answers to the spec, mark it approved. Then
B3 step 4, the traceability table (Sonnet gathers rows, lead reviews), then level 2 (B4) in the
writing order W0; W1 and W3; W2; W4a to W4h; W5.

## Steps

| Step | State | Commit or note |
|---|---|---|
| Strategy Part A approved | done | approval in the decision record |
| B3.6 SSOT baseline line | done | Google Doc tab "Pantas Production Readiness Assessment", 5 Oct entry |
| B9 status file | done | this file |
| B9 hourly resume task | done | desktop scheduled task "pantas-new-design-resume", hourly at about :18; runs only while the desktop app is open |
| B3.1 gap pass | done | raw lists in stage0/ |
| B3.2 kept-work triage | done | stage0/triage.md |
| Stage 0 decisions to Aedwon | answered | answers in the decision record |
| Kept-work cleanup | done | archive/pre-restart-kept-work at 2bdde4fd |
| B3.3 spec update | sent, waiting | specs/2026-10-05-new-design-amendment-design.md |
| B3.4 traceability table | pending | |
| B3.5 execution arrangement | done | recorded in the decision record |
| Level 2 plans (B4) | pending | |
| Level 2 gate review | pending | |
| Level 3 plans (B5) | pending | |
| Level 3 gate review | pending | |
| Stop before level 4, notify Aedwon | pending | |

## Last completed step

Amendment spec sent to Aedwon.
