# Visual pass: make the app match the approved boards

Owner: Claude lead. Started Oct 31. Handoff file: any lead (another account) continues from the
progress table below. Update it after every screen or batch.

## Why

Aedwon, Oct 31: "ui looks terrible. some parts do not look like what was presented to me in Claude
Design. can you please do a visual pass on things and fix as necessary? this is very disappointing
to me". The web layout was built and reviewed against the board files in code only; nobody
compared the running app with the boards visually. Aedwon explicitly asked the lead to do this
visual pass, which authorizes the lead's screenshots for it (WORKFLOW's default is Aedwon-only).

## Sources of truth

- Approved boards: `web-design/pantas-handoff/web/project/<BOARD>.dc.html` (untracked folder in the
  main checkout `/Users/aedwon/Documents/Projects/Pantas/web-design/`), shared CSS
  `web-design/pantas-handoff/web/shared/pantas.css`, rules `web-design/pantas-handoff/HANDOFF.md`
  (hard rules and tokens win). Board map with every board's verdict:
  `docs/superpowers/plans/pwa-launch/web-layout-board-map.md`. Approved later boards:
  `docs/superpowers/plans/pwa-launch/boards/` (R2 debrief, install and welcome, B5 splash, beta
  switch). Later decisions: decision log `docs/superpowers/decisions/2026-10-19-pwa-launch-log.md`
  (Oct 30 and 31 entries: tablet tiers, keyboard hints, Home cards, mistake labels, charcoal dark on
  phones, exam order, no tap ink on web, shared checkbox and radio rows).
- Code: branch `web/staging-candidate-r1` (worktree `/Users/aedwon/Documents/Projects/Pantas-wt-staging-candidate-r1`).
  Fix branch: `web/visual-check-fixes-r1` (worktree `Pantas-wt-vc-fixes-r1`), fast-forwarded into
  staging after each verified batch.

## How to run the app for comparison

- Aedwon's launcher: Spotlight "Pantas Local Test" (runs `~/.local/bin/pantas-local-test`, which
  stops a previous run, pulls staging, starts emulators with CSE content and serves the app; with
  `--lan` at the Mac's LAN address). Logins: `build/local-web/logins.txt` (Free and Pro test accounts).
- For the lead's own screenshots: run `tools/local/run_web_local.sh` WITHOUT `--lan` from the
  staging worktree so it serves on localhost (the browser pane may only operate on localhost), after
  Aedwon's run is stopped (same ports). Open boards through a localhost static server.

## Method per screen

1. Screenshot the app screen at 1440 x 900 (light and dark), then at 390 (phone) and 1180
   (tablet tier) where the board family covers it.
2. Screenshot the matching board at the same size.
3. List every difference (spacing, sizes, radii, colors, type scale and weight, copy, missing or
   extra parts, states, icons) with the board id, in `docs/ui-audit.md` under "Visual pass".
4. Batch fixes per area through Codex Sol (`codex-pick`, low effort; see
   `docs/workflow/orchestrator.md`), the brief quoting the exact differences.
5. Re-screenshot and confirm each fixed difference before marking the screen done.

## Order and progress

| Area | Boards | State |
|---|---|---|
| Onboarding | OB_* | not started |
| Home | HM_*, DK_Home | not started |
| Study and reader | SD_*, RD_* | not started |
| Quiz and answers | QS_*, QN_*, QZ_*, RV_* | not started |
| Mock | MK_* | not started |
| Results and Performance | results, PF_* | not started |
| Record, bookmarks, custom quiz | MY_*, BM_*, CZ_* | not started |
| Settings and Pro | ST_* | not started |
| Plan, More, loading | PL_*, L_*, SY_* | not started |

## Constraints and state (Oct 31, 1:30 AM)

- Codex: account a has no weekly room until Nov 4 14:45; b and c have about 8% and 6% weekly
  (one full 5-hour window is about 16% of a week). Claude Sonnet use was stopped by Aedwon to save
  Claude usage. Gemini through `agy` is available but weak for UI work.
- Beta: ready Nov 7, starts Nov 9 on pantas-prod; Firebase billing waits for Aedwon's card next week;
  runbook `docs/deploy-prod.md` on staging.
- Already fixed from Aedwon's checks (staging 95028544): exam picker and App Check locally, year
  field, arrow keys, Enter, exam order, no web tap ink, Home error once, missing-settings recovery,
  splash until content is ready, duplicate-ID export check, shared checkbox and radio rows.
- Open from Aedwon: onboarding page transitions should be a smooth step change, not a full-page
  slide (needs a preview first).
