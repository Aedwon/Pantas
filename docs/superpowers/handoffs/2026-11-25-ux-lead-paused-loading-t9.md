# UX lead handoff: paused review sheet, loading A, T9 rows with no board (E-155), Nov 25

Policy read from main at 3ed9828f8 (later main refreshed through 4f0431db9). Manager thread: the operations manager. Integrator: the CSE release lead.

## Handed to the CSE release lead (all full CI green; none merged by me)
- `ux/paused-review-sheet-r1` 4a969bdf9: Home reads its question counts again when a quiz is paused or discarded on another tab (Job 1, the "0 of 11" sheet). Close on the sheet was already gone on main (Nov 24).
- `ux/paused-sheet-a-r1` a0c1cc73e: paused option A on the Reviews and New questions sheets (Home and Quiz tab, phone and wide); another paused quiz shows "Finish or discard your paused quiz first." over a dimmed Start; the Reviews header has no count (his 4:06 AM ask).
- `ux/paused-card-r2` f3d0793cf (on top of the sheet branch): Quiz tab paused card to option A, released by him ("yes A lgtm, go ahead with it"): Discard spacing from before Nov 24 (20 above, 24 below the text), "Paused: <quiz name>" for a quiz the rows do not show.
- `ux/loading-a-r1` b0f4dee7a: loading option A (spinner and real percent on one line). Worker counts main.dart.js bytes; total stamped into flutter_bootstrap.js; worker bytes stable across builds. Four Codex Sol High audits, one real-build check. Asked the release lead for a staging proof of a worker update.
- `ux/t9-noboard-r1` 353c48cf2: the T9 rows answered by a source or undrawn with no new look (list in the rulings file, Nov 25 sections).

## Waiting on him
- U24 board (agent audit finding, not his words): https://claude.ai/artifact/A9vWJxf5HnvrvpAtT3xYYq "Home footer without a time". Approved board, Live, A count line (recommended), B no band, C full-width button; light and dark. Not rendered by the lead.

## Records
- Rulings: docs/superpowers/decisions/2026-11-17-fable-backlog-rulings.md, Nov 25 sections (on the branches above and main).
- Launch log: his 3:50 AM picks, 4:06 AM header note, card approval.
- Process entry "Discard spacing in the Quiz tab shrank after a spacing ship (Nov 25)": cause and measured values filled in.
- Reference canvases: Pantas Redesign version 498, Pantas Web version 188 (sheet only); record docs/superpowers/verification/2026-11-25-paused-session-fold.md. The released card is not folded yet: next step for whoever picks this up.
- Captures: build/audit/paused-capture.png and quiz-card-placement.png in the UX lead worktree.

## Open findings, not mine to fix
- pantas_sw.js install can write a new build's shell into the old version's cache (pre-existing; Codex reproduced). Passed to the release lead.
- U86 needs the sign-in provider on the user; U72 kept (its tap starts the clock).
- Local test env: node `yaml` module missing in this worktree makes 6 tool/content tests fail locally; CI passes.
