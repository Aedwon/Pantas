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
