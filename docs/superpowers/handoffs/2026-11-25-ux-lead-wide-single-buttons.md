# UX lead handoff: wide full-width single buttons (E-162), Nov 25

Policy read from main at 23c9053d8. Manager thread: the operations manager. Integrator: CSE release lead r6. Earlier note: `2026-11-25-ux-lead-wide-button-placement.md` (E-158).

## Task
Manager ruling (rule 4) on the "Found, not fixed" single buttons from E-158. His words (Nov 25, about 4:35 AM Manila): "was this never addressed? particularly the placement of discard resume (basically the CTAs in general)?". Rule: design/system/patterns.md, "Button placement". Ruling text and the lead decision on the session results title: rulings file, "Nov 25, UX design lead: wide full-width single buttons (E-162)".

## Handed to the CSE release lead r6 (not merged by me)
- Branch `ux/button-placement-r2` at 3090910d7 (code at ff1714803), based on main 23c9053d8. Full CI: green at ff1714803 (run 45543782442); goldens re-rendered there (45543781456) with no change.
- Wide only; phone unchanged (all five sites are in wide-only code paths; phone tests pass unchanged).
  - Mock setup column: "Start the Mock Exam" at the column's right end at natural width, fine print right-aligned under it (README decision 149).
  - Practice picker panel: "Start" at the panel's right end at natural width.
  - Mock paper side panel (one block, not strict): "Submit the Exam" at the panel's right end at natural width.
  - Onboarding welcome after Back: "Get Started" centered at natural width (was a fixed 260 px box). The first-visit HTML welcome is not touched.
  - Session results: Done top right, level with the centered title (a row with equal sides, no fixed padding); "Start Session N" centered alone under the duration line; both keep their 1700 ms fade. Tab order is now Close, Done, the answer dots, Start Session.
- Kept: the Reviews and New questions drawer's full-width Start or Resume (board A, his pick). It now carries the key `drawer-foot-start`.
- Goldens re-rendered on the CI image (run 45542306369); only `mock_setup_1440` and `session_end_1440` changed, both committed.

## Check
- `test/helpers/button_placement.dart` now fails any wide button built with `expand: true`, unless its key is in `boardFullWidth` (only `drawer-foot-start`). Unit tests added in `button_placement_test.dart`.
- Shown failing on the old code: the mock setup and session results screen goldens at 1440 ("is full width (440 px ...)", "(192 px ...)"), and the new wide tests: picker "Start" (360 px), mock paper "Submit the Exam" (252 px), "Get Started" (260 px), mock setup (590 px in its test).
- Known limit: the mock paper test asserts no full-width button rather than the whole placement check, because the test font is wider than the real one and the natural button fills the panel content there.

## Render sheet
- `build/audit/wide-single-buttons.png` in the UX lead worktree (headless, light, 1440, Before and After per screen). The mock setup row's clipped fine print is the fixture's edge, not the app; the CI golden shows it inside the page.

## Open
- Reference canvases (Pantas Web) still draw the old full-width buttons on MK_SetupCSE, MK_SubmitCSE, the picker panel, the onboarding welcome and the results page; not folded in this task.

## Mistakes
- The first full CI (45542734324) failed the design lint: the results title used a new 136 px literal with no board reason. Rebuilt as a balanced row with no literal; lint baseline refreshed (the onboarding step's counts fell). The watcher printed exit 0 for that failed run because the command ended in an echo; the next watcher read the run's conclusion instead.
