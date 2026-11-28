# Start note for the CSE release lead r7: under-18 close (option C), launch limits, legal texts

Written Nov 25, about 05:55 UTC (1:55 PM Manila) by the CSE release lead r6, which stopped at its restart length before starting this task. Nothing of this task is started: no estimate, no timer, no code. The r7 session is the integrator (only lead that merges to main and ships to prod) and reports to the operations manager thread `mcp:launch:2f628e2495c6e1411884e3ca9e4a1bdc13467273ae2643e58f0fdb984177a926` with t3_thread_send.

Read first: AGENTS.md, WORKFLOW.md, SUBAGENTS.md, docs/workflow/orchestrator.md, docs/workflow/operations-manager.md, docs/workflow/process-improvement.md from main; then `2026-11-25-cse-release-lead-r6-content-fixes-and-placement.md` (current prod, rollback points, ship method, lessons); then the launch-log entry "Nov 25, about 1:50 PM Manila: under-18 sign-up closed (option C) ..." (his words verbatim; already recorded).

## The manager's brief (verbatim, Nov 25 about 1:50 PM Manila)

Do these in critical-path order. Ship each part under the standing ship-it once it is reviewed.
1. Option C, closing under-18 sign-up at the CSE opening: read the ruling in docs/superpowers/decisions/2026-11-17-fable-backlog-rulings.md (the A to D table, the recommendation, and "What C does not remove") in full.
   - The minimum age becomes 18 for new sign-ups, so the approved blocked page shows.
   - The server refuses new guardian requests behind a switch.
   - Handle devices caught mid-request.
   - Accounts a guardian already confirmed keep working.
   - Texts, then one Codex Sol High round through codex-pick.
2. Launch limits at the 500 sign-ups level, from the checklist's "Launch sizing proposal (S3, S4)" (docs/superpowers/plans/2026-11-22-cse-public-release-checklist.md):
   - reCAPTCHA daily cap 1,000;
   - App Check token lifetime 6 hours;
   - prod billing cutoff raised from $15 to $30;
   - account budget email $40;
   - Cloud Run cap stays $5;
   - email stays on Resend Free, with an alert when sign-in mails pass 80 a day.
   His "yes" covers these billing amounts. Count each change against rule 7.
3. Legal texts (PR #110 and the pantas-web legal/public-pages-r1 branch), with the name change. Follow rule 5:
   - An agent redrafts so app screens and the website show the business name, "Pantas Online Tutorial Services". His full name stays only where the law needs it: the controller identity in the Privacy Policy and Terms, and BIR receipts. Check whether the DPO can be named by title and contact rather than by his name.
   - Codex GPT 6.2 Sol High critiques it once through codex-pick (only account b works), leaning in Pantas's favor as far as Philippine law allows.
   - He approves only the result.
   - Publishing then waits on his Google Analytics retention and Gmail labels step, which I gave him. Set the version stamps to the go-live day.
4. Then the build that removes the beta gate. Opening sign-up is his "ship it" moment, so bring it to me first.
Payments stay paused. Log the estimate first, and report to me after each part. Restart from a handoff note if this thread passes about 300 items.

## Standing caps (from the r6 brief)

2 Sonnet workers; every worker brief says "Do not start subagents; do the work yourself." and "Any browser you launch must pass --use-mock-keychain and --password-store=basic, or use tool/journeys or tool/design_system launchers; never kill processes you did not start." One Flutter build at a time on the Mac. No Codex for UI. Codex only through codex-pick, one job at a time (only account b works). Before ending a turn while something runs, start a watcher.

## First steps

1. Read the option C ruling in full and the checklist's S3 and S4; the under-13 lane's guardian code paths (functions and lib) on main.
2. Log the estimate in the velocity log (next free id after E-163; check main first, ids have collided before) and start the timer.
3. Option C, test first; Codex Sol High round; staging proof with a rule 7 pre-run count; prod.
