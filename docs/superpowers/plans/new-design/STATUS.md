# New design restart: status

The single resume point for the engineering restart. Any fresh session resumes from this file
alone. Every step ends by updating this file and pushing it to main.

Controlling documents:
- Strategy (plan of plans): `docs/superpowers/2026-10-05-engineering-restart-strategy.md`
- Decision record: `docs/superpowers/decisions/2026-10-05-engineering-restart-log.md`
- Integration branch: `integration/new-design-r1` (worktree `../Pantas-wt-integration-new-design-r1`)

## Lock

State: held
Holder: Codex lead, chat 01a133c7-407b-7703-9481-a3c689967e8a
Since: 2026-10-13 21:48 Asia/Manila (renewed after usage reset)

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
| Level 4: W4 screen families | W4a through W4f unfinished; W4g not started. W4c Tasks 1 to 4 and reading fraction, W4d start functions/report entry, W4e Tasks 1 and 2, W4b Task 1 and day context integrated. W4d Task 2 partial checkpoint locally committed 0ad018fe (975 affected tests passed); Task 3 resuming. W4c Task 8 draft recovery continues after #9518 timeout; no passing result or commit yet | integration/new-design-r1 at 5e6cda45; current main standing rulings in L3-parallel-map.md |
| Level 4: W6 backend hardening | Tasks 1 to 5c done and integrated (Task 5b, Oct 7); Tasks 6 to 8 (live rules snapshot, deploys, final) remain | integration/new-design-r1 at 739ccae1; gates/w6-astra-audit-1.md |

## Last completed step

W3 accepted and integrated (integration/new-design-r1 at 2d438daf, Oct 12). Lead-run checks on the
merged branch at aa9c0bfb: 3,858 Flutter tests, 84 plain and 92 emulator backend tests; Task 14c
after that changed only the index file and two tests, which pass. W0, W1, W2, W3, W6 Tasks 1 to 5c
and W4h Tasks 1, 2, 3, 5 are integrated.

## Running or scheduled (Oct 13, 9:48 PM)

- RESUMED BY AEDWON Oct 13: "okay resume that. the plan already tells what to do exactly right?"
  The October 18 wait is lifted for the existing approved engineering scope. Live Codex limits
  permit ordinary work (weekly 1% used). Recover and continue two lanes: lane 1 W4d, W4f, W4a;
  lane 2 W4c, W4b, W4e. Astra audits run alone; no browser dispatcher or app screenshots.
  Relay preflight #9488 checks W4d; one relay runner is online. Uncommitted work is preserved.
  Policy read: main c96177bc4495fd2482489b0d44585ea54b3e000b. Implementation, deployment,
  visual acceptance, and publication permissions remain separate.
- At 21:46 Oct 13 Aedwon said "continue". Live usage window is available again (0% short-window,
  16% weekly used). The same Sol workers resumed: W4d Task 3; W4c Task 8 failure recovery.
  W4d local head 0ad018fe64678a26ae8e35af665de5e94c79c45b, clean; remote remains a2a0cb80.
  #9517: 975 affected Flutter tests pass; analysis only the explicitly accepted W4c
  onReorder notice; format, layering, attribution and diff checks pass. #9519 local commit succeeded.
  Task 2 remains partial: Home shared rows/sheets and session metadata still need wiring.
  Independent review/Astra audit, family acceptance, integration and visual acceptance remain pending.
  W4c #9518 timed out at 120 seconds (exit 124); dirty work remains, no task acceptance.
- Integration branch 5e6cda45 (pushed Oct 12; 3,971 Flutter tests pass) now also holds W4c's
  commits through 287a640b (Tasks 1 to 4, reading fraction) and W4d's 4ce76695 and a2a0cb80 (start
  functions, report entry). It is merged into every family branch. All of this still needs its
  Astra audit with the families.
- W4a's merge of the integration branch needed hand resolution in `list_row.dart` and
  `state_view.dart` (W4a and W4c both extended them; both sets of parameters kept; merge commit
  3b2d8b33, not pushed). Expect the same when W4a's work reaches the integration branch. W4a's
  failing tests after the merge are its own uncommitted Task 4 drafts.
- Uncommitted work sits in the worktrees of W4a (5 files), W4c (13), W4d (10), W4f (29, Task 1).
  Do not clean these worktrees.
- Session ids in `w<N>-sid`
  (lead scratchpad); resume prompts `w4x-resume.md`, `w4d-resume2.md`, `w4f-resume.md`,
  `w4b-resume2.md`, `w4e-resume.md`; runner `lane.sh HH:MM job...`.

## Next step

Finish the remaining independent W4d and W4c tasks, recording exact checks and commits as each finishes. Then continue lane 1 W4f/W4a and lane 2 W4b/W4e, and return for the missing cross-family controls. W3 is already integrated into each family base. Required cross-family controls remain unfinished until their owners' contracts land; no family is accepted merely because its independent slice passes. Astra audits run alone before family acceptance/integration. Then W6
Tasks 6 to 8 and W3 Task 15 (deploys, each with Aedwon's approval and his setup steps), W2's
close-out, W4h Task 4, W5. Roles: strategy B7 (Sol builds; Sonnet only when Codex is used up and
only on work no Sol worker started; Astra audits; the reading tier runs checks and exact edits).
Waiting on Aedwon: setup steps (`level4-setup-steps.md`, now with two pass products), privacy text
(`drafts/privacy-pantas-id.md`), the Season Pass renewal line, confirmation of "Could not save your
progress.", a look at the component gallery on a device, image credits, the Sanity upload, E14.
