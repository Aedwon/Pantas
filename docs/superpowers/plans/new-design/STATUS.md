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

Level 4 (building). Levels 1 to 3 passed their gates on October 6, 2026.

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
| Stop before level 4, notify Aedwon | done (Oct 6) | answers recorded |
| Abuse review amendment | done: level 2 gate passed (review 7), level 3 gate passed (review 3) | gates/l3-abuse-gate-3.md |
| Level 4: W0 integration | accepted Oct 6 (Astra audit, lead review); Task 6 not run | integration/new-design-r1 at 13e4f830; evidence/W0.md |
| Level 4: W1 design foundation | accepted and integrated Oct 10 (Astra audit 1 fixed, lead review) | integration/new-design-r1 at 3f0863ab; gates/w1-astra-audit-1.md |
| Level 4: W3 payments and identity | accepted and integrated Oct 12 (Astra audit 1 fixed, Tasks 14b and 14c; lead review); Task 15 deploys remain | integration/new-design-r1 at 2d438daf; gates/w3-astra-audit-1.md |
| Level 4: W2 shared components | accepted and integrated Oct 11 (Astra audit 1 fixed); close-out task after W4 | integration/new-design-r1 at b935cbd2; gates/w2-astra-audit-1.md |
| Level 4: W4h app-wide states | Tasks 1, 2, 3, 5 done and integrated Oct 11 (lead review; 3,730 tests); Task 4 after the other families; Astra audit with the W4 families | integration/new-design-r1 at cee7a9c5; evidence/W4h.md |
| Level 4: W4 screen families | W4a, W4b, W4c in progress; W4d started (no commit); W4e, W4f prepared; W4g not started. Contracts integrated so far: W4b Task 1 and `LessonDayContext` (ffc8045b) | web/new-design-w4[a-f]-r1; standing rulings in L3-parallel-map.md |
| Level 4: W6 backend hardening | Tasks 1 to 5c done and integrated (Task 5b, Oct 7); Tasks 6 to 8 (live rules snapshot, deploys, final) remain | integration/new-design-r1 at 739ccae1; gates/w6-astra-audit-1.md |

## Last completed step

W3 accepted and integrated (integration/new-design-r1 at 2d438daf, Oct 12). Lead-run checks on the
merged branch at aa9c0bfb: 3,858 Flutter tests, 84 plain and 92 emulator backend tests; Task 14c
after that changed only the index file and two tests, which pass. W0, W1, W2, W3, W6 Tasks 1 to 5c
and W4h Tasks 1, 2, 3, 5 are integrated.

## Running or scheduled (Oct 12, 10:40 AM)

- Codex ran out at 10:18 AM (resets 2:04 PM). Two lane jobs (`lane.sh`, lead scratchpad) start at
  2:05 PM, each running its workers one after another:
  lane 1: W4f Task 1 only (new), then W4d resume, then W4a resume;
  lane 2: W4e Tasks 1 and 2 only (new), then W4c resume, then W4b resume.
  Prompts: `w4f-dispatch.md`, `w4e-dispatch.md`, `w4d-resume.md`, `w4a-resume3.md`,
  `w4c-resume3.md`, `w4b-resume2.md`; session ids in `w<N>-sid`.
- Lead rulings of Oct 12 are in L3-parallel-map.md (standing rulings) and the W4a, W4b, W4c plans.
- State of the branches: W4a 1af8dc0b plus uncommitted drafts (Tasks 2, 3, 5 done); W4b ffc8045b
  (Task 1 and the Task 3 type, integrated); W4c e38a65a4 plus uncommitted work (Tasks 1 to 4
  done or in progress); W4d no commit. The integration branch (ffc8045b) is merged into W4a, W4c
  and W4d; lead full checks on it were running at 10:40 AM.
- As contract commits land (W4f Task 1, W4e Tasks 1 and 2, W4d Task 1 and report entry, W4c
  reading fraction): lead reviews, merges them into the integration branch, and merges that into
  the waiting branches when their workers are idle.
- Sol has started W4a, W4b, W4c, W4d; W4e and W4f start at 2:05 PM. Only W4g is free for Sonnet,
  and it waits for W4b Task 8 and W4f Task 5.

## Next step

Review and integrate W4a and W4c when their workers finish. W4b, W4d, W4e, W4f and W4g also need W3 integrated (after its audit and fixes). Then W6
Tasks 6 to 8 and W3 Task 15 (deploys, each with Aedwon's approval and his setup steps), W2's
close-out, W4h Task 4, W5. Roles: strategy B7 (Sol builds; Sonnet only when Codex is used up and
only on work no Sol worker started; Astra audits; the reading tier runs checks and exact edits).
Waiting on Aedwon: setup steps (`level4-setup-steps.md`, now with two pass products), privacy text
(`drafts/privacy-pantas-id.md`), the Season Pass renewal line, confirmation of "Could not save your
progress.", a look at the component gallery on a device, image credits, the Sanity upload, E14.
