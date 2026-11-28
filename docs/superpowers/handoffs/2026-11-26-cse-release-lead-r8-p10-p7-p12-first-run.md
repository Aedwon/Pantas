# CSE release lead r8: P10, P7, P12, the guided first run on prod, service worker paused

Written Nov 26, about 21:40 UTC (5:40 AM Manila) by the CSE release lead r8 (integrator). Read this instead of the r8 thread. Policy read from main c0ce2891f and refreshed through 6654f2a11. Manager thread: mcp:launch:00976645432b2f793e42bfeeea73583c727484762376837beea722b8a3c65b8d (new since Nov 26). Launch log entries for every part are on main (Nov 26).

## Current prod

- Web: build 1774060561-cb80f572cf8a from main 2c9cf8a87 (BETA_GATE=true), Worker d2a72e17-f423-4042-8d8d-e953a2a992bd, shipped 20:58 UTC, watch clean. Rollback: Worker b3d2f5a6 (`Pantas-private/releases/2026-11-26-first-run-ship/rollback.md`, also the content rollback).
- Functions: #109 (43 functions, with P7's recordLessonRead) and #136 (5 functions), deployed by the security lead after the integrator's go; watches clean.
- Content: P10 mock text uploaded (root `content/cse-key-fixes-r1` a7cc22b6b plus main's acet.yaml, custom_subject_tiers.json, illustrations/sources/pantas.yaml; those three are copied uncommitted into the cse-key-fixes-r1 worktree; export at the r8 scratchpad, rebuild it with main's tools if gone).
- Staging: build 396422457-df61add7eaa5 from main 2c9cf8a87.

## Done this session

Link-preview image (#134); P10 (#137); P7 (#138); P12 runs on today's worker (study, quiz, mock, report, sync); web mock navigation hotfix (#143, prod 19:20 UTC); Record figures (#144); guided first run integrated (#142); his staging pass and two refinements (#146); merged for the security lead: #109, #91, #136, #139, #140, #141, #145; the prod ship above.

## Open, in order

1. P12 offline, resume after reload and update loops on today's worker (backlog C13). Count rule 7 first.
2. Next batched prod web update (low-use hours only, his rule until the new worker ships): Study title 2 px at 390 and the report confirmation for screen readers (backlog C14).
3. The opening (checklist G1 to G6): legal publish (PR #110, pantas-web branch), version stamps, gate-off build with SELLER_*, the live-key step at 9 AM Manila (security lead), his real test payment, then `PAYMONGO_CHECKOUT_OPEN=true` and createPaymongoCheckout redeploy (#139). Checklist G3 lists the steps.
4. Service worker option A after the opening (backlog C12): branch fix/sw-build-mix-r1 8aadb36da with the fix list; clean Codex audit and a 48-hour staging soak before prod. Velocity E-184 timer paused.

## Lessons

- The prod content root is a content branch plus three main files, not main's content folder; main's CSE mock files lack the comprehension weights. Edit content on the branch.
- `firebase deploy` must use the pinned CLI (`npx --prefix functions firebase ...`); the global one does not load functions/.env.
- Codex exec waits on open input; codex-pick now closes it (process entry Nov 26).
- Before accepting a golden that changes text layout, read it for line breaks and alignment against sibling screens (process entry Nov 26).
- Cloudflare can serve a stale version.json for a short while after a deploy; check with a cache-busting query.

## Branches and worktrees

Merged and removable after the usual check: ux/og-image-r1, fix/p10-figures-r1, fix/first-sync-batch-r1, release/first-run-r1, fix/mock-roamable-range-r1, fix/record-figures-r1, fix/staging-pass-refinements-r1, hotfix/mock-roamable-r1 (prod hotfix, superseded by the ship). Keep: fix/sw-build-mix-r1 (worktree cse-sw), content/cse-key-fixes-r1 (worktree cse-key-fixes-r1, prod content root). Worktrees reused this session: ops-retire-firebase, ship-google-button, cse-ent06-ship, cse-docs-ent06, qa-cse-content-fixes-r1-e2be285e666bb7e9 (build/web holds the prod build).
