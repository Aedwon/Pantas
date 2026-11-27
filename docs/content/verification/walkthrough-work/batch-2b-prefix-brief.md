# Brief: batch 2b fixes before the pre-check (E-206)

Read `docs/content/verification/walkthrough-work/batch-2a-r1-fix-brief.md` in full first, and the briefs it names. All of
its rules, hard limits and checks apply. Lead's policy commit `be4ec2f41`.

## Fixer (lessons)

1. `content/lessons/mathematics/algebra/motion-meeting-and-separation.md` joins batch 2b. Fix its two Codex read 2
   Blockers in `docs/content/verification/walkthrough-work/codex-math-2a-r2.md`, by pattern across the whole lesson:
   - Add speeds only for two objects moving in opposite directions along the same line (apart or toward each other). Say
     so in the rule, the pair note (about line 73) and the checklist line (about line 139). Same direction: subtract.
   - Late start: the summed speed gives the change in the gap only while both move. For meeting, use the gap at the moment
     the second object starts. For moving apart, the gap that opens while both move is the final gap minus the gap at the
     second start. Keep it short: one or two sentences, with no new example unless a sentence cannot carry it.
   - Then re-solve every number in the lesson, and check that no other line says "add the speeds" without the condition.
2. Display lines in the batch 2b lessons (`content/lessons/mathematics/`): `arithmetic-number-sense/adding-and-multiplying-fractions.md`,
   `fractions-and-mixed-forms.md`, `multiplying-and-dividing-decimals.md`, `operation-priority-and-left-to-right.md`,
   `grouping-and-fraction-bars.md`, `distribution-and-common-factors.md` (all under `arithmetic-number-sense/`). One move
   per display line: split any line that does two moves, such as "$6-8+4=-2+4=2$", into one line per move, each ending at
   its value. The lesson checks require each display line to end at a value, so a split line is "$6-8+4=-2+4$" then
   "$-2+4=2$". Change nothing else.

## Figure worker

Follow `docs/content/verification/walkthrough-work/figure-draw-brief.md` (hard rules, Round 2 and Round 3 rules, checks).
The lead renamed the existing chart in `content/illustrations/mathematics/data-interpretation/chart-scales-and-differences/`
to `02-bar-chart-titled-factory-output.svg`. Draw the new row for that lesson (`batch-2-figure-list.md`, the "line 51"
row) as `01-<slug>.svg`, and put its marker right after the worked lines that print 50, 35 and the 15 difference, outside
any `:::` block, so it is the first ILLUSTRATION marker in the lesson. Touch only that lesson and that folder.

## Report (each, under 250 words)

Fixer: each change in one line, any number you re-solved, words before and after, the three checks' output lines.
Figure worker: the brief's picture report.
