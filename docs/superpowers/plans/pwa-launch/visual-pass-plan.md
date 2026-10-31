# Visual pass: make the app match the approved boards

Owner: Claude lead. Started Oct 31. Handoff file: any lead (another account) continues from the
progress table below. Update it after every screen or batch.

## HANDOFF for the next orchestrator (read this first)

State at Oct 31, 3:40 AM Manila (Opus on Aedwon's first account, weekly limit at 96%):

1. Policy: fetch `AGENTS.md`, `WORKFLOW.md`, `docs/workflow/orchestrator.md` from origin/main.
   Reply rules for Aedwon: short, plain, no em dashes, American spelling.
2. Goal: make the web app match the approved Claude Design boards (Aedwon's request quoted in
   "Why"). Area order and state: the progress table below. Only onboarding has started.
3. Setup that already works:
   - Boards: `/Users/aedwon/Documents/Projects/Pantas/web-design/pantas-handoff/web/project/*.dc.html`
     (untracked). `support.js` (Claude Design runtime) is now next to them, so templated boards render.
   - App: from `/Users/aedwon/Documents/Projects/Pantas-wt-staging-candidate-r1` run
     `tools/local/run_web_local.sh` (no `--lan`) in the background; ready when
     http://localhost:7357 answers and emulators finish (about 1 to 2 minutes). Aedwon's own
     "Pantas Local Test" run uses the same ports: only one at a time. Stop with `pkill -f run_web_local`.
   - Capture scripts in `build/visual-pass/` of that worktree (gitignored): `capture.mjs` (helpers;
     its DARK_RULES board patch is invented, do not use it), `ob_pairs.mjs` (first 6 steps),
     `ob_pairs3.mjs` (latest: state boards, verification print of each app screen's labels,
     real runtime). Output `shots/ob/<BOARD>-pair.png` (board left, app right, top 640 px).
   - App driving: `http://localhost:7357/?localAccount=free`, click `#pw-start`, click
     `flt-semantics-placeholder` to enable semantics, then click elements by aria-label.
4. Open script problems (latest run):
   - "My exam isn't listed" click does not open the custom flow (CustomName and CustomCover shots
     show the picker). Find its real semantics label.
   - Date day click: day cells are labeled by bare numbers ("10", "11"); check OB_DateMonth and
     OB_DateDay shots actually show a month and day picked.
   - AgeBlocked (ArrowUp x4 from 2012) and Days (click Mon..Sat) and Name: not yet visually checked.
   - Always check the printed labels or the image before comparing a pair.
5. Next steps: finish onboarding comparisons (pairs not yet viewed are listed in the findings
   below), then write the full difference list into `docs/ui-audit.md` "Visual pass" on branch
   `web/visual-check-fixes-r1` (worktree `Pantas-wt-vc-fixes-r1`), fix (Codex Sol via `codex-pick`
   if it has room, otherwise yourself), re-capture to confirm, fast-forward staging, then the next
   area. Show Aedwon side-by-side images for anything that needs his judgment.
6. Not done and out of scope here: dark mode and 1180/390 comparisons (boards are light 1440;
   check the board map for which families have phone boards), Gemini runs (quota until about Nov 5).
7. Done Oct 31: onboarding fix batch 1 (Codex Sol plus a lead fix to the Terms row height) is on
   `web/visual-check-fixes-r1` and staging at bcb4b981. Analyzer clean; onboarding and core UI tests
   pass (853). Re-captured: search field, "isn't listed" icon, Coming soon pills, plain day cells and
   Back arrow now match. Remaining: app step content now sits about 3 to 5 px LOWER than the board
   (overshoot); re-check Terms, Name and DateKnown pairs; AgeBlocked and CustomCover still not reached.
   Aedwon, Oct 31: "how about remove the check inside lol just outlined". Done (staging b14a5515):
   web exam cards show no radio and no check; the picked card gets a 2 px accent outline drawn on
   top (no shift) and the accent tint. Aedwon then: "just design it like the board but remove the
   check inside". Done (staging 143fa7b4): board card exactly (tint #E4F1EE light / accentTint dark,
   2 px outline, 64 px min height, padding 11/14/11/16, no hover fill), no check. Phone picker
   unchanged. The bottom bar is on the board too, so it stays.
   Re-checked after fixes (staging 143fa7b4): OB_Terms matches (the board image shows a dark
   disabled label only because its runtime did not apply `.cta.off`; the board CSS is the faded
   #AEAEB2 label with an outlined Enter chip, as in the app). OB_Name: close; the field is still
   about 49 px vs the board's 55 px. Not re-checked: OB_DateKnown (no capture script step yet).
   Local run note: after stopping, wait until port 8080 is free (the Firestore emulator exits
   slowly) before starting again.
   Codex sandbox note: `codex-pick exec -s workspace-write` cannot write git metadata of a worktree
   (fetch and commit fail even with `--add-dir .git`). Prefetch policy into `build/policy-*.md` and
   tell Codex not to fetch or commit; the lead commits. Flutter tests also cannot run in that sandbox;
   the lead runs them.
9. Oct 31 afternoon (Opus, account c): all 21 reachable onboarding boards now compared at 1440
   light (`build/visual-pass/ob_pairs5.mjs`: fixes the year and text typing, fakes the date to
   Wed Oct 14 2026 to match the boards; `measure.mjs`/`rows.mjs` give exact pixel rows). Not
   reachable by script: PickerLoading, PickerError, PickerEmpty. SignIn and Restoring belong to
   Settings. Reminders, ReminderTime, Permission are NEW-FEATURE; Install is SKIP.
   Fix batch 2 brief: `build/vp-ob-brief-2.md` in the fixes worktree (section gap 24 on wide date
   and picker pages; action row gap 28 on Days and 32 on DateKnown; onboarding buttons 48 px;
   Every Day aligned to chips; name fields 56 px with 2 px border; custom subject rows 56 px; day
   grid 4 px gaps, no outline on Today, equal panel heights; too-late card icon and US date
   order; AgeBlocked header, position and padlock). Implementing: Sonnet subagent, lead reviews,
   tests and re-captures. Aedwon, Oct 31: "are you delegating changes to sonnet? please do, you
   do the reasoning, it does the doing".
   Decided, Aedwon Oct 31: "today can count as study day". The too-late card keeps suggesting
   today; the board's "Thursday or Friday" is not followed there.
   Done: batch 2 is on `web/visual-check-fixes-r1` and staging at 081a82b1 (analyzer clean, 861
   onboarding and core UI tests pass). Re-measured in the browser: name field, subject rows and
   date known buttons pixel exact; the rest within 1 to 5 px (date picker weekday row about 4 px
   low, under-13 block about 4 px low). Record: `docs/ui-audit.md` "Onboarding fix batch 2".
   Faster loop for later areas: back up `build/web/index.html`, `pantas_pwa.js`,
   `local-login.html`, run only `flutter build web --profile --no-web-resources-cdn -t
   lib/main_dev.dart --dart-define=LOCAL_EMULATOR_HOST=127.0.0.1`, restore the three files; the
   running local server serves the new build (about 2 minutes instead of a full restart).
   Gotcha: on desktop web, Material's compact visual density removes 8 px from button minimum
   heights; use `VisualDensity.standard` where a board height must hold.
   Sample students (Oct 31): fixes branch 77fbfe4c adds local-only `?localStudent=new|steady|behind|examWeek`
   (with `?localAccount=free|pro`). The local server seeds the student through the server's own
   session, lesson and mock code (`tools/local/seed_student.mjs`). Do not fake the browser clock:
   App Check rejects it. Home board checklist (Haiku): staging worktree
   `build/visual-pass/home-boards.md`. Split agreed with Aedwon: Sonnet captures, measures and
   drafts differences; the lead reviews and spot-checks; Haiku crawls.
   Next: Home (HM_*, DK_Home), capture in progress. The local test panel (spec and plan approved) is paused until the
   visual pass is done (Aedwon: "finish the screens first").
8. Cost guide: about 10 board comparisons per 1% of a Pro weekly limit when pairs are cropped.
   Aedwon asked to track usage per step; note it in the findings.

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
| Onboarding | OB_* | Done at 1440 light: 21 of 24 BUILD boards match (3 picker states unreachable); batches 1 and 2 on staging 081a82b1 |
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

Second run (`ob_pairs2.mjs`, pairs cropped to the top 640 px to save image cost):
- Blocker: the boards load `./support.js` (the Claude Design runtime), which is not in the handoff
  folder. 19 of 305 boards use its templates (`{{...}}`, `<sc-for>`), including OB_Days*,
  OB_Date{Day,Month,Year,ThisMonth,Today}; served with a stub they show raw `{{d.short}}` text.
  Resolved Oct 31: the same runtime from `/Users/aedwon/Documents/Projects/aedwon/v3-design/reference/support.js`
  renders OB_Days correctly with no errors; it is now copied next to the boards in
  `web-design/pantas-handoff/web/project/support.js`. Board servers must serve it, not a stub.
- Script fixes needed: typing a year did not reach the field (AgeBlocked shot shows Terms); OB_Days
  needs a day picked before Continue works (Name shot shows Days); the "isn't listed" click did not
  open the custom flow; date month and day labels are dumped to `shots/ob/date*-labels.txt` for
  the month and day click patterns. Check every `-app.png` shows the intended screen before comparing.
- Third run viewed (lead, Oct 31, weekly 96% to 97%):
  - OB_Days: close match (board now renders). The app's chips sit slightly closer to the subtitle and
    the "6 study days a week" block is tighter than the board's; shared offset as above.
  - OB_Name: the app's name field is shorter than the board's (about 46 px vs 55 px). Board shows a
    typed name with Done on; the app shot is empty with Done off (state only).
  - OB_DatePick: close match. The empty-panel calendar icon differs (app: calendar with a dot grid;
    board: plain outline calendar) and the app's two help lines are smaller.
  - OB_DateDay: every day cell in the app has a gray filled background; the board's day cells are
    plain text with no fill (only the picked day is filled teal). Clear difference.
  - OB_AgeBlocked: still not reached (ArrowUp presses did not change the year; the shot shows Terms).
    Focus the field first (click the year text) or type into the input element.
  - OB_CustomName (reached in `ob_pairs4.mjs`, whose click helper now picks the smallest matching
    element and also matches inputs): same short text field as OB_Name (about 46 px vs the board's
    55 px; the app's text is also smaller). Otherwise a match.
  - Still not reached: OB_CustomCover (typing did not reach the name field; click the field first,
    then type) and OB_AgeBlocked (same cause: click the year field, then select all and type).
  - Not viewed: OB_DateMonth (expect the same day-cell finding), OB_Terms re-capture.
  - Onboarding fix list so far: step content offset and Back chevron (all steps); Terms row height,
    spacing and disabled Continue; Picker search field, chips, "isn't listed" row, card radio vs
    check badge (check decision), Coming soon pill, bottom bar; date tile month label and button gap;
    day cells without fill; empty-panel calendar icon and help text size; text field height and
    text size (Name, CustomName).
- OB_Days (app only, board unreadable): the app's day chips and "Every Day" plus disabled Continue
  row are present; compare once the board renders.

Usage note for estimates: this onboarding work (capture script, 6 comparisons, these notes) took
about 1% of the Claude weekly limit on the Pro plan (95% to 96%), at about 32% of a 5-hour window. The second run (script, 4 cropped pairs, this note) stayed
within the same 1% (96%). Rough rate: about 10 board comparisons per 1% weekly on Pro.
