# CSE release lead r2: Nov 24 UI release and open work

Written Nov 24, 13:58 UTC, when the UI release went live. Read this instead of the old thread.

## Shipped (prod 13:50 UTC, web only)

Main eafd9e61a, PR #114 (carries #112, #113). Launch log: "Nov 24, UI release shipped to prod".
- Quiz bar to Aedwon's own design (his words and mock recorded in the launch log): no answer dashes, no hints, flag centered, no flight into results. Phone and wide.
- Borderless buttons (T5) to the approved boards, including no Close area under the lesson contents sheet.
- "Discard this session" centered under Resume (board QZ_Resume).
- Rollback: Hosting version dc0a4bbe72d8d304, Worker e9347b49-687a-4569-a592-58a4c2ff30f5.

## Rule now in force

Before any prod ship, list each user-visible UI change and the board Aedwon approved that draws it. A change only a council, Fable or a lead designed goes to the manager with a mock first, not to prod.

## UI list, in order (manager, Nov 24)

1. Study and Quiz spacing (T6): branch qa/layout-spacing-r1, worktree /Users/aedwon/.t3/worktrees/Pantas/cse-layout, commits through 9ac1e08ca (U6, U7, U10, U11, U12, U13, U15). Its worker did not finish its report. Next: list the category (c) rows still open against build/audit/t6-brief.md in the qa/cse-release-r1 worktree, independent board review at 390 and 1440, CI, ship.
2. Splash off-center on wide web: brief build/audit/splash-brief.md (qa/cse-release-r1 worktree). Board: Web_B_Still and Phone_B_Fade.
3. Delayed loading indicator: no board of his draws it, so it needs a mock to the manager first. Load causes: build/audit/load-perf-brief.md.
4. 47-segment reader progress bar replacement: board in Claude Design first (rule 3), then the manager.
5. T16 B4, B3, B1 (Core Loops canvas, council-designed: each needs his pick on a board before it ships). T7, T8, T9 minors and phone fixes (build/audit/later-items.md holds found items). T11 beta surfaces (app.pantas.study still shows beta screens). T12, T13, T20. T17 (PR #91) is the security lead's.
6. Pulley figures (two Majors from the content re-check): the single fixed pulley and the movable pulley painters draw wrong ropes. App drawing code, lib/core/ui/figures/pulley_system_figure.dart; fixes in the private re-check file, findings 15 and 16.

## Paused: legal texts (PR #110)

Branch legal/publish-r1 (app texts word for word, a test compares them with the signed-off files; version stamps 2026-11-24 in app and functions; CI green on 91ef12a72). Website pages: pantas-web branch legal/public-pages-r1 (/privacy, /terms, /teens; beta notice moved to /beta-privacy). Every build claim in the H5 table is true on prod. Left: Aedwon confirms Google Analytics retention is 2 months with "Reset user data on new activity" off; he creates Gmail labels pay-2y and hold; set the stamps to the actual go-live day (two app lines and one functions line, named in the PR); merge; deploy functions, web and the website; verify live; launch-log entry. The sales invoice sentence is left out until checklist M8 is met. Velocity E-144 timer paused.

## Waiting: CSE content fixes

Content tree prod serves: branch content/cse-key-fixes-r1 (worktree cse-key-fixes-r1, from content/cet-bite-r1 d97de9415). The Nov 24 audits read main, not prod; a re-check against prod (private: Pantas-private/audits/2026-11-24-prod-recheck/recheck.md) found 8 Blockers and 13 Majors still applying, 35 already fixed. Codex applied the fixes with lead overrides (fix-prompt.md and fix-report.md in that folder); not yet verified by the lead. Left: lead review of fix-report.md, an independent re-solve of every edited question, approval through tool/content/approve.dart with evidence, export, rule 7 count, staging, prod upload. The CSE Professional mock changes to 150 practice questions plus 20 personal-data items. Velocity E-145.
