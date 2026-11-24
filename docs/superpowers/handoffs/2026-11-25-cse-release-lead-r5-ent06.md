# CSE release lead r5: ENT-06 shipped; reader dashes merged, waiting on the manager

Written Nov 24, 19:45 UTC. Policy: main 77b813afe (AGENTS, WORKFLOW, SUBAGENTS, orchestrator, process-improvement). Earlier state: `2026-11-25-cse-release-lead-r3-spacing-splash.md`; the week strip ship (r4) is in the launch log.

## Shipped (prod 19:40 UTC, web only)

ENT-06 from T17: web counts an active `beta_reward` grant as that exam's Pro, for any exam, as the server's coverageAt does. Aedwon's 18 owner rows now show Pro on every exam; testers who turn on their reward see Pro at once. Main 61fbd1b56 (PR #119), build 451189975-7c2341db9875. Launch log: "Nov 25, web counts tester rewards and the owner grant as Pro (ENT-06)". Not proven on a signed-in account; Aedwon's reload is the check.

Review: one Codex Sol High run (private: `Pantas-private/security/2026-11-23-money-path-audit/ent06-review-2026-11-25.md`). Fixed: refresh after activation, switch warning crash, test clock.

## Left from the review (not built)

- Medium, display only: checkout return reports success when an unrelated reward is active while the bought grant is still pending (`restorePurchases` uses `hasKnownCoverage`).
- Medium, display only: Settings trial countdown and Pro page end date take the longest end, which can be a reward's.
- Medium: no refresh at a reward's start or end; content fingerprint keeps ended exam keys (same as beta today).
- High, server, already tracked as PAY-06: a paid plan for an exam a reward does not cover can be queued behind the reward.
- Rest of T17: ENT-12 (stale entitlement replies) and pass rows in the connected list.

## Waiting on the manager

ux/reader-lesson-pills-r1 (PR #120, wide reader without the per-lesson dashes) is merged into main (1d4a5e579, CI green) but not on prod. The manager decides whether prod waits for Aedwon's look at `Pantas-handoffs/2026-11-25-reader-indicator/`. If go: build main from 1d4a5e579 or later, same steps as the ENT-06 entry, then fill E-154.

## Worktrees

cse-ent06 (branch qa/ent06-beta-reward-r1, merged), cse-ent06-ship (detached 61fbd1b56, holds the prod build) and cse-docs-ent06 (docs) can be removed once the reader ship is done.
