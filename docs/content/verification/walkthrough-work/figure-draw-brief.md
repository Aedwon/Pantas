# Brief: draw the pilot lessons' pictures (E-206, P0 first case and P2)

Lead: walk-through Math lead, batch 2. Plan: `docs/superpowers/plans/2026-11-27-walkthrough-math-batch-2.md`, section
"Pictures" (P0 result and lead ruling: pictures are SVG files on the ILLUSTRATION route).

Read in full first:
1. `docs/content/verification/walkthrough-work/figure-pipeline-notes.md` (written by the P0 worker; "Steps to add one
   figure" is your procedure).
2. `docs/content/lesson-svg-authoring.md` from main: read it in the main tools worktree
   `/private/tmp/claude-501/-Users-aedwon--t3-worktrees-Pantas-content-lesson-walkthro-85719f9d9f054ca1/e9af84d4-e298-4015-a487-439b46cd24bf/scratchpad/maintools`
   (detached at main `be4ec2f41`; read only, never edit it).
3. The style template: `content/illustrations/mathematics/data-interpretation/table-values-and-totals/01-table-titled-quarterly-office-expenses.svg`
   in this worktree. Use the same theme color tokens, fonts, background and text sizes.

Startup: retrieve `AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md` from current GitHub main and follow them.

Worktree: `/Users/aedwon/.t3/worktrees/Pantas/content-lesson-walkthro-85719f9d9f054ca1`, shared with the lead and one lesson
writer. You may change only: the lesson files named below (marker lines and, for the triangle, one sentence), and new SVG
files under `content/illustrations/mathematics/`. Use the Edit and Write tools only. No shell command that changes a file.
Do not commit; the lead commits. If you hit a Claude usage limit, stop at once and report what you changed.

## Hard rules

- Every number and label in a picture equals the lesson text right beside it. Re-read that text after you draw and list
  each number with the line it matches.
- A picture explains a relation; no decoration, no icons, no extra words.
- Every marker is `<!-- ILLUSTRATION: full description -->` on its own line, outside any `:::` block. The description says
  what the picture shows in full, because it becomes the alt text. The file is `NN-slug.svg` where NN is the marker's order
  in that lesson (01, 02).
- An ILLUSTRATION marker without its file breaks the export, so never leave one without a file.
- Do not change any other lesson text, check, try, pair or checklist.

## Work, in order

1. Percentage Base and Fraction Division
   (`content/lessons/mathematics/arithmetic-number-sense/percentage-base-and-fraction-division.md`):
   - 01, the part-and-whole bar, replacing the `FIGURE WANTED` note at line 23: one horizontal bar labeled
     Base = 200 (100%), split into a shaded left part Part = 60 (Rate = 30%) and an unshaded right part 140 (70%). The bar
     widths are to scale (30% and 70%). These numbers equal line 25 ("30% of 200 is 60").
   - 02, the part, rate and base triangle, on its own line right after the three formulas (after the
     $$\text{Rate}=\dfrac{\text{Part}}{\text{Base}}$$ line) and before the "Try finding the base" paragraph: a triangle
     with Part in the top section, a horizontal line under it, and Rate and Base side by side in the bottom section with a
     multiplication sign between them. Add one sentence of at most 20 words right under the marker that says how to use it,
     for example: "Cover the one you want: the other two show whether to multiply or divide." The three formulas above it
     must match the triangle.
2. Then, if step 1 passes its checks, the other pilot notes, one at a time, each only if the numbers in its note still equal
   the text beside it (if not, use the text's numbers; if the note's picture no longer fits the text, skip it and say why):
   - `arithmetic-number-sense/discounted-prices.md` note at line 79 (price bar: Php 800 = 100%, 25% discount Php 200,
     75% paid Php 600).
   - `algebra/mixture-word-problems.md` note at line 58 (three containers).
   - `data-interpretation/percentage-change.md` note at line 43 (100 to 80 and back to 100).

## Round 2 (batch 2a and three pilot lessons; after `ee1f274b3`)

Source: `docs/content/verification/walkthrough-work/batch-2-figure-list.md`, the rows for your lessons (the lead accepted
every row). Each row gives the spot, what the picture shows, and its numbers. Before drawing, re-read the lesson text
beside the spot: if a number in the row differs from the text, the text wins; say so in your report. Replace an existing
`FIGURE WANTED` note with the `ILLUSTRATION` marker at the same spot; for a new row, put the marker on its own line at the
spot named. Number files by marker order in the lesson (`01-`, `02-`). Do not add any sentence to the lesson in this
round. Hard rules and Checks above apply; you may also run the full draw (Check 3) at most once, and skip it if it fails for
the same `assets/seed/content.db` reason as round 1.

- Figure worker 1, under `content/lessons/mathematics/arithmetic-number-sense/`: `simple-interest.md`,
  `compound-interest.md`, `commission-and-sales-tax.md`, `markup-on-cost.md` (2 pictures),
  `successive-percentages-and-increases.md`, `decimal-and-percent-conversions.md` (pilot).
- Figure worker 2, under `content/lessons/mathematics/`: `algebra/motion-chase-problems.md`,
  `algebra/motion-meeting-and-separation.md`, `arithmetic-number-sense/inverse-proportion-and-remaining-work.md`,
  `arithmetic-number-sense/partitive-proportion-and-differences.md` (2 pictures), `algebra/age-word-problems.md` (pilot),
  `algebra/work-rate-problems.md` (pilot).

Each worker touches only its own lessons and their SVG folders.

## Round 3 (batch 2b; after `4dd7e1e48`)

Same rules as round 2, plus what Codex read 1 of batch 2a found about pictures:
- A picture sits after the text that introduces its numbers, never before the story or values appear. Put the marker right
  after the setup line or the worked line whose numbers it shows.
- If a picture draws amounts as lengths, heights or areas, they are to scale, or the shapes carry no implied size (no
  waterlines, equal boxes only where the amounts are equal).

One worker. Rows in `batch-2-figure-list.md` for these lessons under `content/lessons/mathematics/` (7 pictures):
`arithmetic-number-sense/adding-and-multiplying-fractions.md` (move the existing note to Example #1 step 1, beside
"3/4 = 9/12", as its row says), `arithmetic-number-sense/multiplying-and-dividing-decimals.md`,
`arithmetic-number-sense/distribution-and-common-factors.md`, `data-interpretation/chart-scales-and-differences.md` (the new
row at line 51 only; the existing bar chart stays as it is, and the new marker's NN follows marker order in the lesson, so
rename nothing that exists: if the new marker comes first, report it and stop for the lead), `data-interpretation/inverse-proportion-and-ratio-parts.md` (2),
`data-interpretation/percentages-and-ratios-of-groups.md`.

## Round 4 (batch 2c; after `0e8b93aa0`)

Same rules as rounds 2 and 3. One worker. Rows in `batch-2-figure-list.md` for these lessons under
`content/lessons/mathematics/arithmetic-number-sense/`: `coprime-divisibility-tests.md`,
`divisibility-by-seven-and-eleven.md` (its row proposes the "Test 2,728" paragraph; put the marker right after that
paragraph's worked lines and remove the old note at line 56), `last-digit-divisibility.md`, `greatest-common-factor.md`,
`least-common-multiple.md`, `prime-factors-and-powers.md`, `same-remainder-numbers.md`, `imaginary-unit-and-powers.md`.
`real-number-sets.md` keeps its code figure; do not touch it. If a lesson already has a drawn ILLUSTRATION and the new
marker would come before it, stop for that lesson and report it.

## Checks

1. SVG validator, no Flutter: `python3 -I <maintools>/tools/check_lesson_svgs.py <root> --validate-only`, where `<root>` is
   the content root form the tool expects (see its usage and the pipeline notes; this worktree's `content` folder).
   Fix every rejection for your files. Ignore rejections in files you did not touch, but list them.
2. Parser and words for each lesson you touched:
   `cd /private/tmp/claude-501/-Users-aedwon--t3-worktrees-Pantas-content-lesson-walkthro-85719f9d9f054ca1/a0b12a19-1dc0-47c5-b136-c30710a95094/scratchpad/parser && dart run run.dart <absolute paths>`
   (expect failing: 0) and `dart run wc.dart <absolute paths>` (at or under 900 each).
3. The full two-theme draw, once at the end, through the machine lock only:
   `L=/Users/aedwon/.t3/worktrees/Pantas/qa-cse-release-r1-485b9ecb7345be22/build/audit/flutter-locked.sh`, then
   `$L python3 -I <maintools>/tools/check_lesson_svgs.py <root>` from the directory the tool's docs require. If the lock
   is held for more than 10 minutes, skip this check and say so. Never take a screenshot.

## Report (under 300 words)

Per picture: file path, marker line, every number and label with the lesson line it equals, the check output lines. Any
note skipped and why. Any rule you broke.
