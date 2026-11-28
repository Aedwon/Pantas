# CSE release lead r10 to r11: after the opening; service worker in progress; content waits for the 4 PM reset

Written Nov 28, about 5:05 AM Manila (Nov 27 21:05 UTC), by the CSE release lead r10. Manager thread
c517ddef-dfdb-4aa6-9f0a-401e7c34873d (messages start "Manager:"; reports start "CSE release lead r11:").
Policy: read AGENTS.md, WORKFLOW.md, SUBAGENTS.md and docs/workflow/process-improvement.md from main first. The
launch log entries of Nov 27 and 28 (from "final staging proof of the opening build passes") hold every step.

## Standing rules for this lane (manager, Nov 28)

- You are the only build lane. At most 1 worker at a time (Aedwon: "slow down"). The split may wait a day rather
  than add a second worker.
- Rule 7: no content run on staging or prod before the quota reset at 08:00 UTC (4:00 PM Manila); "testing never
  bills". Before every upload-tool run, count the day's reads (`node tool/checks/free_tier_live.mjs` from a main
  checkout). The tool now refuses a run over budget itself: staging 40,000, prod 25,000 (40,000 minus a 15,000
  real-user reserve). At most 3 upload-tool runs per project per item.
- Every upload: read the exit code; if not 0, rerun at once; the re-plan must show `"update":0` and
  `exam summaries: unchanged`.
- Prod web is frozen until service worker option A passes a clean Codex audit and a 48-hour staging soak (his "A",
  Nov 26). Content uploads are allowed.
- Worker briefs: Edit or Write only for files; Bash plain read-only, git and existing tools with plain arguments;
  no attribution trailers in commits (CI scan rejects them); browser flags --use-mock-keychain --password-store=basic.

## Prod now

- App: opened Nov 28 12:05 AM Manila. Worker a46d4772, build 3144721425-ef93293efe40 (main 890325dee). Rollback
  points and the runbook: `~/Documents/Projects/Pantas-private/releases/2026-11-28-opening/runbook.md`.
- Checkout open to everyone (createPaymongoCheckout 00026; main e97158bf9 matches).
- Website: pantas-web main 4e0d077, version 4f2e652c (beta button removed, legal dates Nov 28).
- Live content root: `content/cse-math-qfix-2b-r2` 34f3c7e24 (opening step 4 content, ratio 0020, mixture 0010 and
  0016, order-of-operations 0019, word-problems 0022, Math pilot 9 lessons, batch 2a 13 lessons). Rollbacks are in the
  launch log per upload.
- Staging: web from main 0b46728ef (UI fixes, PR #164) with getSetupAcceptance; content matches prod.

## Next, in order

1. **Service worker option A** (E-210, timer running). Branch `fix/sw-build-mix-r1` at 36fad2f39 (pushed), worktree
   `/Users/aedwon/.t3/worktrees/Pantas/cse-sw`. Done: the audit 2 fix list and every open finding (c38f279ca and
   before); part 2 commits 687f3413f (pin full CanvasKit) and 36fad2f39 (Firebase SDK from our own address, one
   renderer). The part 2 worker hit the Claude limit before it reported: its test runs are NOT verified. Brief:
   scratchpad copy at
   `/private/tmp/claude-501/-Users-aedwon--t3-worktrees-Pantas-qa-cse-content-fixes-r1-e2be285e666bb7e9/e301a76f-487d-4727-8b87-8e8d9747a5fc/scratchpad/sw-brief-2.md`
   (if gone: rulings are "serve the Firebase JS SDK from our own origin in the build folder, precached and verified;
   pin full CanvasKit for every browser and precache only that variant"). Next: (a) rerun every test the brief lists
   and confirm the committed cold-offline test passes; (b) the manager's condition: one golden sheet of Home, a lesson,
   a quiz question and Pro on Chrome at 390, today's renderer against the pinned full CanvasKit, local build and
   emulator only, pixel counts per screen; any visible difference goes to Aedwon's staging check during the soak;
   (c) Codex GPT 6.2 Sol High audit 3 through `codex-pick` (non-UI), against the fix list and audits 1 and 2
   (`~/Documents/Projects/Pantas-private/releases/2026-11-26-sw-option-a/`); (d) clean audit, then PR, merge, staging,
   48-hour soak, then prod with his word through the manager.
2. **After 4 PM: the combined content upload.** A scheduled one-time wake-up (scheduled-task:0c3c0e83-59c9-40da-9a10-292126cebc7f,
   08:05 UTC) is bound to the r10 thread; if you are fresh, do it yourself. Branch `content/cse-math-2bc-r1` b3e75d128,
   worktree `/Users/aedwon/.t3/worktrees/Pantas/cse-math-2b`: Math 2b (13 lessons, Operation Priority and Grouping from
   8ad01f238 with 3-part numbering), 2c (10), 2d (10 of 12), and the five held 2a lessons (397df5186): 38 lessons, 29
   picture files; every changed file equals the Math lead's stack at 07cf0289e; lesson checks pass. Upload tool: main's,
   from `/Users/aedwon/.t3/worktrees/Pantas/upload-summary-fix` (detached at main; run `npm run build --prefix functions`
   first after any main update). Steps: count reads, export, content gate, one staging upload and re-plan, one Sonnet
   picture check of every new picture (light and dark at 390, and each after the text that gives its numbers; hold any
   lesson that fails), one prod upload and re-plan. The first run on each project builds the version list (about 1,500
   reads). Main's three files `content/mock/acet.yaml`, `content/exams/custom_subject_tiers.json`,
   `content/illustrations/sources/pantas.yaml` sit uncommitted in each content worktree, equal to what is live; keep them.
3. **Then the signed-integer split, its own run.** Branch `content/cse-math-split-r1` c872e24d9, worktree
   `/Users/aedwon/.t3/worktrees/Pantas/cse-math-split`, built on b3e75d128 (if a lesson is held in step 2, move the
   split onto that final head first). Done: 2 lessons, 3 pictures, retirement, renumbering, 4 relinks, 6 new questions
   blind-solved and approved, prerequisites, outline, 14 gap tags; lesson checks, validator, export and content gate
   pass. Record `docs/content/verification/split-signed-integers-r1.md` on the branch. Left: staging upload, a check of
   its 3 pictures, prod upload.
4. **Aedwon's staging check after 4 PM** of the UI fixes (steps were sent to the manager: sign out to Welcome, the
   Sign in link, a returning sign-in that skips Terms, the lesson spacing and option A on
   https://staging.pantas.study/lesson/lesson-arithmetic-number-sense-discounted-prices).

## Open items

- Velocity: E-210 (service worker) timer still running; E-209 stopped (1 h 56 min) without its row's actuals on main;
  E-202 and E-203 rows are on main.
- Launch log: no entry yet for PR #165 closed and #166 (upload budget check and version list, merged 9cfc90ac1),
  PR #167 (nested-boxes figure, merged 464794c98, ships with the next app update), the batch 2c and 2d branch work, and
  the split preparation. Add them with the next record.
- Disk was at about 15 GB free; a cleanup task protects these worktrees: cse-sw, upload-*, cse-math-*, cse-qfix-2b,
  the qa-* ones and the opening ones (cse-candidate, cse-opening-prod, pantas-web-home-opening).
