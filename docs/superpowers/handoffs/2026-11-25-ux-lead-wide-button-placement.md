# UX lead handoff: wide button placement, code only (E-158), Nov 25

Policy read from main at d7ccfed7c (later main refreshed through 6503109c4). Manager thread: the operations manager. Integrator: CSE release lead r6.

## Task
His words (about 7:25 AM Manila): "i think the button placement sweep is excessive, isn't there a faster way to determine that without using screenshots", then "okay proceed" to a code-only scan. Rule: design/system/patterns.md, "Button placement".

## Handed to the CSE release lead r6 (not merged by me)
- `ux/button-placement-r1` bdc0a3222 (main merged in at 8b806fb92), full CI green (45531546012). Quiz tab card already shipped (launch log, 7:48 AM Manila), as the brief required before this hand-off.
- Fixed, each with a wide test that failed on the old code: Quiz tab mock card (action at the right end, natural width, 44; Change the Setup before it in one row); guardian confirm and waiting (one right-aligned row, secondary first); Settings exam change confirmation (one centered row, Done then Change Exam Date; phone unchanged); seven pairs to 8 px (Account sign-in footer, session results, note editor, paused mock, Home passed card, Home notice, install card).
- Home state card now reads the layout's web platform, so the wide Home golden shows the wide card a real browser shows (no change on the web itself).
- Goldens re-rendered on the CI image (45514216823) and committed for the five changed images only: home_1440, quiz_tab_1440, quiz_tab_paused_1440, session_end_1440, home_beta_notice.
- CI shard 0 hung after all its tests passed (run 45527232551): `router_settings_test` never exits when bundled after `router_screen_views_test`. It hangs the same way with main's lib code and passes alone; my new test files only reshuffled the bundles. Moved it to `tool/ci/bundle_excludes.txt` (the existing remedy). Root cause not found: the process sits idle at 0% CPU and a per-test timeout does not fire; closing the first test's content database did not help. Open for whoever owns CI.

## Check
- `test/helpers/button_placement.dart`: reads the laid-out screen; fails a wide pair out of order, off 8 px (board exceptions listed with his approval: board A's 16 on the Quiz tab paused card), stretched, neither at the right end nor centered, or stacked phone-style; and a lone button spanning its box. Runs on every wide screen golden through `screen_harness.dart` and in the new tests.
- Shown failing before the fixes: mock card (5 states), guardian (2), exam change (1), and each of the seven gaps.
- Tuned, with reasons in the rulings file: filter chips left out (choices, not actions); a pair within a card's 32 px right padding counts as the right end (foot bands with no text; cards whose icon pushes the text in, the install card). After tuning: 0 problems on the 32 wide screen goldens.

## Renders (headless, one per screen whose new look no board draws)
- build/audit/quiz-tab-mock-card-wide.png, guardian-confirm-wide.png, guardian-waiting-wide.png, exam-change-wide.png in the UX lead worktree (local renders; the committed goldens are from the CI image).

## Records
- Rulings: docs/superpowers/decisions/2026-11-17-fable-backlog-rulings.md, "Nov 25, UX design lead: wide button placement, code only (E-158)", with the search named.
- Scan table: docs/superpowers/verification/2026-11-25-wide-button-placement-scan.md.
- Process entry "Wide Quiz tab paused card still breaks the button placement rule he set": sweep and check recorded as done. The same commit removed merge-conflict markers left in that file on main (both sides kept).

## Open, for the manager
- Wide full-width single buttons not fixed (outside the pair scan): mock setup column (MK_SetupCSE), practice picker panel, mock paper Submit (MK_SubmitCSE), fixed-width Get Started (onboarding welcome) and Done (session results). patterns.md says side panels put the action at the bottom right at natural width; the boards that drew 100% predate the rule. Say if they should be fixed.
- Reviews drawer foot keeps its full-width Start (board A, his pick), which differs from the drawer rule in patterns.md. Kept because his pick wins.

## Mistakes
- I launched one empty extra agent by error (a third agent against the cap of 2). It did nothing; no files touched.
- I ended my turn while the goldens run was going without registering the watcher with the thread, so the session ended, the watcher stopped, and the lane sat idle about 1 h 37 min until the manager asked. Process entry added.
