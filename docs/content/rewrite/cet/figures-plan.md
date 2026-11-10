# CET lesson figures

November 10, 2026. Policy read from origin/main 2b7b1ddbd. Spec P2 (figure markers) and the approved style D (`docs/content/rewrite/figure-style/`). Manager, relaying the resume: start the figures with a two-figure pilot, then continue; redraw the earths-motions sidereal-day figure.

## Scope

194 ILLUSTRATION markers in 68 of the 77 CET lessons. Question figures (renderer `figureSpec`) are not part of this pass. Batches of about 12 markers by lesson path: `figure-batches.json` (19 batches).

## How the app joins files to markers

The k-th ILLUSTRATION marker in a lesson takes the k-th figure file of that lesson's folder in file-name order (`tools/content/markdown_portable_text.dart` on `web/lesson-svg-r1`). So every marker needs exactly one file, numbered in marker order, or the later markers take the wrong figure. Three lessons already have approved PNGs (mixtures-and-separation 01, nuclear-chemistry 01, layers-of-the-earth 01 and 02). For those, the lead checks which marker each PNG belongs to before any SVG is numbered, and keeps each PNG in its slot.

## Steps per batch

1. **Briefs (Sonnet).** One brief per marker, from the lesson, in the CSE brief format (`docs/content/rewrite/figure-briefs/`), saved to `docs/content/rewrite/cet/figure-briefs/<subject>__<topic>__<lesson>.md`. A marker that sits before a worked solution must not show the answer or the method.
2. **Drawing (a fresh Sonnet).** From the briefs only, following `SONNET-FIGURE-INSTRUCTIONS.md`. The SVG checker (`tools/check_lesson_svgs.py` from `web/lesson-svg-r1`) must report 0 failures.
3. **Lead look.** One contact sheet per batch, light and dark, rendered offscreen (`tools/content_rewrite/figure_sheet.py`, then macOS `qlmanage`). The WORKFLOW exception of November 9 allows this. The lead checks layout, overlaps and that each figure matches its marker. Fixes go back to the drawer.
4. **Accuracy check (Opus).** A fresh Opus reads each SVG's labels and coordinates against its marker and the lesson text around it: values, labels, nothing invented, nothing that gives away a worked answer.
5. Commit per batch. Aedwon's visual check of the figures in the app comes at the review package.

## Pilot (November 10)

functions-and-relations, 2 figures. Briefs about 67k tokens; drawing about 70k, plus 75k for one fix round after the lead's render (label overlaps in both figures). Values and curves were correct on the first draw. Batching briefs and drawings per batch should bring this to about 40k tokens per figure.

## Results

(Appended per batch.)
- Pilot accuracy check (Opus): both figures PASS.
- Batch 13 (thermodynamics-and-kinetics 2, earths-motions 7, earths-subsystems 1): 10 figures. The lead's render sent back 3: in the Orion-through-the-year figure, the June label sat on the night-sky arrow; the closest-and-farthest orbit was a strong ellipse, which supports the misconception that distance causes the seasons, so it is now a near circle marked "not to scale"; a label touched the panel edge. Opus accuracy check: all PASS. The lead removed a duplicate dashed line in the energy profile. The earths-motions sidereal-day figure is redrawn with "about 1°" (the round-6 removal is resolved).
- Known: `check_lesson_illustrations.py --phase review-ready` lists every CET marker as "unexpected", because its inventory (`docs/content/illustrations/`) predates the rewrite; it already failed before this phase. Updating that inventory is a last step of this phase.
- Batch 1 (quadratic-equations 3, systems-of-equations 3, circles 4): 10 figures, no send-back. The brief writer flagged that the quadratic-inequality markers in Examples #9 and #12 sat before their solutions and asked for the roots and the solution region, which give the answer. Following the standing marker ruling, the lead moved both markers unchanged to after their solutions. Opus accuracy check: all PASS, move confirmed clean. Note: the circle figures are drawn to scale, so an answer could be measured off the drawing; no answer is labeled, and this was passed.
- Batch 2 (coordinate-geometry 4, parallel-perpendicular-lines 8): 12 figures. The brief writer flagged three coordinate-geometry markers (Examples #5, #7, #8) whose values are the worked answer; the lead moved them unchanged after their solutions (`tools/content_rewrite/move_marker_after_solution.py`) and the briefs were made faithful. The drawer first drew four angle figures with the brief's fixed 60° transversal, so "110°" sat on an acute angle; the lead sent them back and every labeled angle is now drawn at its true size. One misplaced intercept label fixed. Opus accuracy check: all PASS, moves confirmed clean.
- Rule added for later batches: angle and coordinate figures are drawn to their true values.
- Batch 3 (quadrilaterals-and-polygons 10): 10 figures. The Example 11 marker (diagonals that make a rhombus) moved unchanged after its solution, because the drawing shows the answer. The Example 3 figure follows the round-5 ruling: a label box hides part of the polygon, so its side count cannot be read. The lead's render check passed all 10, with geometry measured against the lesson values. The lead moved one label ("60°" in figure 05) next to its angle. The Opus accuracy check for this batch was not run, because the work paused first. Run it on resume.

## Paused, November 10

Aedwon, through the manager: usage goes to the items ahead of CET. Stopped after batch 3. Nothing is running.

- Figures drawn: 44 of 194 (pilot 2, batch 13 10, batch 1 10, batch 2 12, batch 3 10). Accuracy-checked: 34. Batch 3's Opus check is pending.
- Batches left: 4 to 12 and 14 to 19, in `figure-batches.json`. Batch 1's functions-and-relations is done.
- Resume: run the Opus accuracy check on batch 3 (`fig-checker` brief in this plan's step 4). Then continue at batch 4 with the same four steps. The scratchpad prompts (`brief-writer.md`, `drawer.md`, `fig-checker.md`) are summarized in the steps above, and their added rules are: draw angles and coordinates at their true values, and a writer flags any marker whose values give away a worked answer, so the lead moves it after the solution.
- Last step of the phase: update the illustration inventory under `docs/content/illustrations/` so `check_lesson_illustrations.py` knows the new markers.
