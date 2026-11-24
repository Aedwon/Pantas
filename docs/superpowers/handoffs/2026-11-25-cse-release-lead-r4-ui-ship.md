# CSE release lead r4: pulley, tester items, T9 rows, and four prod ships (Nov 25)

Written Nov 25 by the CSE release lead r4. Read this instead of the r4 thread. Earlier notes: `2026-11-24-cse-release-lead-r2-ui-release.md`, `2026-11-25-cse-release-lead-r3-spacing-splash.md`. Policy read from main eb3b68782 and later.

## Shipped to prod today (launch log has each entry with board, rule 7 count, staging proof, rollback)

1. Week strip chip "CSE Pro" and "CSE Subpro" (PR #118, U14): shipped by r4 at about 19:20 UTC.
2. ENT-06, web counts tester rewards and the owner grant as Pro (PR #119): shipped by a second session (r5) at 19:40 UTC.
3. Wide reader without lesson dashes (PR #120) with UI ship r4 (PR #117): shipped by r5 at 19:48 UTC. #117 carries:
   - Pulley figures redrawn to correct physics (re-check findings 15 and 16): fixed pulley, one rope over the wheel, load on one side, effort pulled down on the other; movable pulley, anchor on the beam, rope under the wheel, free end pulled up, load on the axle. Same style.
   - Tester-only beta items removed (manager ruling Nov 25): day and survey Home notices, Settings Feedback row and survey pages, the expired Beta Pro switch. Kept: sign-in gate, beta and waiting screens, BETA mark on sign-in, "Pantas beta" link-preview image (a new image needs his pick), and the earned-reward notice plus a "Beta Reward" Settings row, both only for an earned, not activated reward (the server accepts activation until Jan 1, 2028). The manager's Nov 23 reward list shows 0 eligible testers, so nobody sees them today.
   - T9 rows built to approved boards or plain correctness (map: `docs/superpowers/verification/2026-11-25-t9/t9-map.md`): P1, P3, P26, U46, U47, U48, U50, U68, U71, U75, U82, U93, U96, P24 (set A); LI5b, P6, P10, P12, P13, P18, U73, P20, P21, P22, U18, U39, U51, U80 (set B). Independent review at 390 and 1440 found them matching.
4. Home reads its counts again after a quiz is left part way (PR #121, UX lead E-155): shipped by r4 at 21:01 UTC.

Current prod: build 36769871-950bb63789f4, Hosting c6f5b07c1f8d9538, Worker 34aa29dc-c734-41e0-b334-20005b01f694.

## In flight

- Paused-session option A (UX lead branch `ux/paused-sheet-a-r1` at a0c1cc73e, his pick on https://claude.ai/artifact/9MLsiFtEwsdLodfe8eHZig; Reviews header count removed per his 4:06 AM words). Independent review: matches, with two build-worse items being fixed on `qa/paused-a-fixes-r1` (worktree cse-t9-a): the wide Reviews drawer Close X sits 13 px below the one-line title; phone "Discard" sits 2 px low. Lead decision (rule 4): the wide "another quiz is paused" state, which no board draws, keeps the build's line above a dimmed Start, as on phone. Next: PR, CI on current main, staging proof, prod, launch log.
- The UX lead's loading option A (spinner with percent) and the T9 no-board rows come next from the UX lead.

## Held back, with the reason

- P9 Google sign-in button states: L_SignIn and ST_AccountOutA draw different buttons, and the built motion did not match L_SignIn. Reverted; needs a board pick.
- P23 and U70 delete-progress steps: the deletion is one server call, so two steps would be invented progress.
- U87 backup page rows: the board conflicts with his Nov 8 ruling, and two rows have no data.
- LI4 figure labels over strokes: needs stroke geometry in label placement, not a quick fix.
- U19 plan history "finished both of them": the log stores only a finished count, not the total, so the sentence can be untrue. Reverted.
- U92 wide pause timing: no board draws it. U94 phone finale timing: the board changed since the motion was taken from it; matching it means redoing approved motion.
- Pulley (1,1) branch (fixed plus movable, questions 0002, 0009, 0013, 0018): same missing anchor and arrows; outside findings 15 and 16 and the re-check accepted 0013. Fix only if the content lead wants it.
- 37 NO BOARD rows in the T9 map (LI1 to LI3, LI9, P7, P11, P17, P25, U17, U20 to U29, U32, U33, U36 to U38, U40, U49, U52, U69, U72, U78, U81, U84 to U86, U89 to U91): the UX lead has them.

## Open from the ENT-06 Codex review (not fixed; payments paused)

A reward can defer a paid plan for another exam until the reward ends (PAY-06, security lead); checkout can report success on an unrelated reward while the bought grant is pending; Settings can show another exam's reward end; web does not refresh Pro at reward start or end. Only the owner's grant rows are affected today.

## Process

- Entry added: "Two lead sessions shipped the same PRs at once (Nov 25)". r4's ship worker for ENT-06 was stopped at staging after r5 shipped; prod was never touched. Its staging user and debug token were deleted.

## Branches and worktrees

Merged and removable: fix/pulley-figures-r1 (cse-pulley), qa/beta-tester-surfaces-r1 (cse-beta-surfaces), qa/t9-set-b-r1 (cse-t9-b), release/ui-nov25-r4 (cse-release-r4), ux/paused-review-sheet-r1 (cse-121). Still in use: cse-t9-a (paused A fixes), cse-docs-r4 (docs). Build output in each is deleted on removal.

Velocity E-149.
