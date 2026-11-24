# CSE release lead r3: Study and Quiz spacing and wide splash shipped

Written Nov 24, 16:25 UTC. Read this instead of the r3 thread. Earlier state: `2026-11-24-cse-release-lead-r2-ui-release.md` (its UI list and paused work still stand, except items 1 and 2 below).

## Shipped (prod 16:10 UTC, web only)

Main 0db28d00f, PR #116. Launch log: "Nov 24, Study and Quiz spacing and wide splash shipped to prod". It lists each change with its board, the rollback (Hosting 3ab826bcbfdae0a8, Worker a19948b5-0a8f-4b08-910e-dc1b54918da7) and the staging proof.
- UI list item 1, Study and Quiz spacing (T6): category (c) rows U3 to U7, U10 to U13, U15 shipped; U8 already fixed by the quiz bar.
- UI list item 2, splash centered on wide web (1024 px and up); phone unchanged.

## Left from items 1 and 2

- U9 Pro hero eyebrow: the ST_ProFree drawing (sparkle beside PANTAS PRO inside the hero, radius 24) conflicts with design rulings 126 and 188 (188 approved by Aedwon Nov 8) and with contrast; reverted, prod unchanged. If the manager wants the board version, it needs Aedwon's pick between the board and ruling 188.
- U14 long CSE exam names in the Home week strip: no board; needs a mock to the manager first.
- Phone splash: Phone_B_Fade centers the group at 50%; the app keeps 42% from the Nov 10 phone fix. Not changed; a manager question if wanted.

## Branches and worktrees

qa/layout-spacing-r1 (worktree cse-layout), qa/splash-center-r1 (cse-splash) and release/ui-nov24-r2 (cse-release-r3) are merged into main by PR #116; their worktrees can be removed in cleanup. Their build output is deleted.

## Next (not started, per the manager)

UI list items 3 onward in the r2 handoff: delayed loading indicator (mock first), reader progress bar (board first), T16 picks, minors, beta surfaces, pulley figures. Legal texts and payments stay paused by Aedwon. CSE content fixes wait (velocity E-145).
