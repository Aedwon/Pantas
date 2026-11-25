# CSE release lead r4: Nov 25 UI ships, held items, and the service worker gap

Written Nov 25, 23:58 UTC (7:58 AM Manila) by the CSE release lead r4. Read this instead of the r4 thread. Earlier notes: `2026-11-24-cse-release-lead-r2-ui-release.md`, `2026-11-25-cse-release-lead-r3-spacing-splash.md`. Policy read from main eb3b68782 and later. Velocity row E-159 (first logged as E-149, which the UX lead also used).

## Current prod

Build 157224851-6c123c02e3d0, Hosting f3854d6641dc1dfa, Worker 1826b9f9-0042-4d77-ade3-74e6fb8f81ec, from main d4f665ec4. Rollback: Hosting c0458f33ce518823, Worker 72b8cd00-679b-4e2f-9ef0-69dd3aec88f4. Every ship below has a launch-log entry with its board, rule 7 count, staging proof and rollback.

## Shipped today (UTC)

1. 19:17 Week strip "CSE Pro" and "CSE Subpro" (PR #118, U14).
2. 19:40 ENT-06, web counts tester rewards and the owner grant as Pro (PR #119), shipped by a second lead session (r5).
3. 19:48 Wide reader without lesson dashes (PR #120) with UI ship r4 (PR #117), by r5. #117: pulley figures to correct physics (re-check findings 15, 16); tester-only beta items removed (manager ruling; kept: sign-in gate, beta and waiting screens, BETA mark, link-preview image, and the earned-reward notice plus a Beta Reward Settings row for an earned, unactivated reward; 0 testers eligible per the manager's Nov 23 list); 28 T9 rows built to boards or plain correctness (map: `docs/superpowers/verification/2026-11-25-t9/t9-map.md`).
4. 21:01 Home re-reads its counts after a quiz is left part way (PR #121, UX lead E-155).
5. 22:03 Paused-session option A on the Reviews and New questions sheets (PR #122). One slip shipped: the Quiz tab wide Reviews drawer Close X sat about 11 px low (fixed in 7).
6. 22:40 Splash loading row with a real download percent (PR #123). First-time visitors see the spinner only; returning visitors and updates see the percent.
7. 23:07 PR #124 went out with the U24 footer counts, which the manager then withdrew (Aedwon decided the footer Oct 31: "Leave it out"). Rolled back at 23:11. PR #125 reverted U24 on main.
8. 23:48 #124 without U24: Quiz tab paused card option A (his "yes A lgtm, go ahead with it"), the T9 rows a board or ruling answers, the drawer Close X fix.

## Held, waiting on a board pick or data (not built or reverted)

- New looks no approved board draws: U52 grey wide reader quiz button, U78 sidebar skeleton, U26 Pro skeleton tiles, U81 Performance skeleton shapes (reverted from #124, commits on ux/t9-noboard-r1), and P9 Google sign-in button states (L_SignIn and ST_AccountOutA disagree).
- Needs data or a pipeline change: P23 and U70 delete-progress steps (one server call), U87 backup page rows (conflicts with his Nov 8 ruling; no data), U19 "finished both of them" (only a count is stored), U86 (sign-in provider data), U72 (Start starts the clock).
- Motion or timing with no current board: U92 wide pause timing; U94 phone finale (board changed since the motion was taken; matching means redoing approved motion).
- LI4 figure labels over strokes (needs stroke geometry); pulley (1,1) branch (questions 0002, 0009, 0013, 0018) has the same missing anchor and arrows, outside findings 15 and 16.
- Phone Quiz tab paused card: Discard text measured about 22 px above and 30 px below (target 20 and 24). More room, not less; for the UX lead.

## Service worker gap (backlog, trigger: before the beta gate drops for public launch)

- Defect: offline, the worker can serve one build's shell (page, flutter_bootstrap.js, pantas_pwa.js, version.json) with another build's main.dart.js. Mechanism (confirmed in a Node harness): a worker that still controls the page after a deploy stores the new build's network-first shell in its own cache, next to its own cache-first Dart files. Six tests reproduce it on today's worker; parked with skip on branch fix/sw-build-mix-r1 (commit ecdc85656; the failed minimal fix is fee671e77 below it). Not for main.
- Codex GPT 6.2 Sol High audit of the minimal fix (store only if a fresh version.json names this build): FAIL. Blocker: a fresh version.json does not prove which build another response's bytes came from; edge skew, stale asset bytes, or a B to C to B rollback still mix builds. High (predates the fix): a new worker can activate and delete the old cache before it has its own Dart files, so going offline right then leaves the app unable to boot; an old worker can cache new metadata or parts from an open tab before the new worker takes over.
- Option 1 design (needs Aedwon to lift the Nov 14 "No new worker or hosting migration ships"): the build stamps a list of each file's content hash into the worker or bootstrap (tool/web/stamp_worker_version.mjs already stamps); the worker stores a response only if its bytes match the hash for its own build; install precaches and verifies the complete boot set (shell, main.dart.js and parts, the database worker) before skipWaiting; activate deletes old caches only after that; runtime stores outside the list are refused. Tests: the parked six plus a real-browser rollout from today's prod worker. Phones on today's worker stay exposed until the new worker activates (needs a connection). About 1 day with two Codex audits.

## ENT-06 open items (Codex review, not fixed; payments paused)

A reward can defer a paid plan for another exam until the reward ends (PAY-06, security lead); checkout can report success on an unrelated reward while the bought grant is pending; Settings can show another exam's reward end; web does not refresh Pro at reward start or end. Only the owner's grant rows are affected today.

## Process (entries on main)

- "Two lead sessions shipped the same PRs at once (Nov 25)": one integrating session per PR; ship briefs re-check the live build right before the prod deploy.
- Ship briefs now say: if any staging proof check fails, stop before prod (a worker shipped #122 past one).
- Not logged as an entry, for the manager: a stopped ship worker can still have deployed; after stopping one, check the live build and Hosting releases at once (this caught #124).
- Two ship workers printed private values to their own tool output (the seller phone once; a throwaway staging password and short-lived token once); nothing was logged or committed; briefs now say never to print them.
- Codex accounts a and c return 401 (logged out); only b works.

## Branches and worktrees

Merged into main and removable: qa/paused-a-fixes-r1, qa/loading-a-integrate-r1, qa/paused-card-integrate-r1, qa/t9-noboard-integrate-r1, release/ui-nov25-r6, fix/revert-u24-r1, qa/t9-set-a-r1, fix/r4-ci. Worktrees still on disk: cse-t9-a (all merged, clean; remove), cse-sw (fix/sw-build-mix-r1, parked; keep), cse-docs-r4 (docs; remove). Build output in each is deleted with the worktree.

## Next

Content fixes after the UI (manager): CSE content key fixes, velocity E-145, state in the r2 handoff, "Waiting: CSE content fixes". Start them in a fresh session from this note (this thread is past the Nov 24 restart length). Legal texts and payments stay paused by Aedwon.
