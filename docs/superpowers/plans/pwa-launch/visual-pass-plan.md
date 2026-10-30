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

## Revised pipeline (Oct 31, Aedwon approved): Gemini looks, Claude fixes

Aedwon, Oct 31: "make sure to have Gemini do its thing first before you do your thing" and "i want
it to be effective, not efficient". Fixes: "when my other account resets tomorrow ... at 2 PM, I'll
have it do the fixes" (another Claude account, Sat Nov 1 2 PM Manila).

Work folder: `build/visual-pass/` in the staging worktree (gitignored build output).

1. Capture (Gemini via `agy`). A script screenshots every board and its matching app screen at
   1440x900, 1180x820 and 390x844, light and dark, against the localhost app
   (`tools/local/run_web_local.sh`, no `--lan`). Output `build/visual-pass/shots/<BOARD>/`.
   `build/visual-pass/coverage.md` lists every board with its app route and needed state, or why
   the app cannot reach that state yet.
2. Compare twice (two independent Gemini runs). Fixed checklist per pair: layout and alignment,
   spacing, sizes, radii, colors, type size and weight, copy, icons, missing or extra parts, states.
   The script also writes a pixel overlay per pair. Outputs `build/visual-pass/run1.md`, `run2.md`.
3. Merge. Confirmed: both runs found it, or one run plus a visible overlay difference. Otherwise
   "check". Output `build/visual-pass/differences.md` and a side-by-side contact sheet
   `build/visual-pass/review.html` for Aedwon.
4. Aedwon reviews the sheet and marks wrong or fine.
5. Fix (Claude, Aedwon's other account, from Nov 1 2 PM) per area, then re-capture and re-compare
   until every confirmed difference is gone. Record fixed items in `docs/ui-audit.md`.

Status Oct 31: the first Gemini run hit its Google quota (resets about Nov 5) after starting step 1
on onboarding. Partial work in the staging worktree `build/visual-pass/`: `capture.mjs`,
`seed_onboarding.mjs`, test screenshots. No comparisons yet. Next: whichever account has room runs
steps 1 to 3 from `build/visual-pass/BRIEF.md` (copy kept there), reusing the partial script.
Aedwon, Oct 31: "Other account Saturday". His other Claude account runs steps 1 to 5 from Nov 1
2 PM Manila; it starts the localhost app itself (`tools/local/run_web_local.sh`, no `--lan`).

## Order and progress

| Area | Boards | State |
|---|---|---|
| Onboarding | OB_* | 6 of 28 boards compared at 1440 light (lead, Oct 31); fixes not started |
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

## Onboarding findings (lead, Oct 31, 1440x900 light)

Capture: `build/visual-pass/ob_pairs.mjs` in the staging worktree (board left, app right, saved as
`shots/ob/<BOARD>-pair.png`). It drives the app with `?localAccount=free` and semantics labels.
It stops after OB_DateKnown: the "That's Right" button label did not match `/^(Yes|Continue)/`;
use `/^That's Right/`. Not yet compared: OB_Days, OB_Name, and all state boards (AgeBlocked,
Picker loading/error/empty, Custom*, Date* variants, Days* variants, SignIn, Restoring), dark,
1180 and 390.

- All steps: the app's step content sits about 4 to 6 px higher than the board; the Back chevron is
  smaller and thinner than the board's.
- OB_Welcome: matches.
- OB_Age: matches apart from the shared offset above.
- OB_Terms: board rows are taller (about 57 px vs 41 px in the app) with more space between the
  subtitle and the card. Disabled Continue: board shows dark label on a light gray pill; the app
  shows a faded gray label.
- OB_Picker:
  - Search field: board is white with a light border; the app is a gray filled field.
  - Filter chips: board labels are darker and heavier than the app's.
  - "My exam isn't listed": board has a plus-in-circle icon on the left and a dark title; the app
    has no icon and a teal title.
  - Exam cards: board has no radio; the selected card gets a teal border and a teal check badge on
    the right. The app shows a radio circle on the left of every card. Check against the Oct 31
    shared radio row decision before changing.
  - Coming soon: board shows a small gray "Coming soon" pill on the right of the card; the app adds
    a third text line.
  - The app shows a white bottom bar with Continue; the board shows none in the first screen.
  - Expected, not differences: Civil service listed first (exam order decision); nothing preselected.
- OB_DateKnown: close match. The app's month label in the date tile is smaller, and the gap between
  "Different Date" and "That's Right" is smaller than the board's (about 8 px).

Usage note for estimates: this onboarding work (capture script, 6 comparisons, these notes) took
about 1% of the Claude weekly limit on the Pro plan (95% to 96%), at about 32% of a 5-hour window.
