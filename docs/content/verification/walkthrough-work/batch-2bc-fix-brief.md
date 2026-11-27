# Brief: batch 2b Majors fixed once (after its last read), and batch 2c pre-check fixes (E-206)

Read `docs/content/verification/walkthrough-work/batch-2b-r1-fix-brief.md` in full first, and the briefs it names. All of
its rules, patterns, hard limits and checks apply. Lead's policy commit `be4ec2f41`.

## Fixer A: batch 2b, the one Major fix

Codex read 2 of batch 2b PASSED (0 Blockers, 11 Majors). Fix each `Major` row in
`/private/tmp/claude-501/-Users-aedwon--t3-worktrees-Pantas-content-lesson-walkthro-85719f9d9f054ca1/e9af84d4-e298-4015-a487-439b46cd24bf/scratchpad/codex/2b-r2/batch-2b-r2.md`
as it says, in the smallest change that does it. No further Codex read follows and the lead checks every diff, so change
nothing else. Minors: no change. Line numbers are at `d8a86b31e`. Files: the lessons those rows name (fractions-and-mixed-forms,
multiplying-and-dividing-decimals, operation-priority-and-left-to-right, grouping-and-fraction-bars,
distribution-and-common-factors, commutative-and-associative-properties, inverse-proportion-and-ratio-parts,
percentages-and-ratios-of-groups, motion-meeting-and-separation). For the commutative try: keep it the faded last step of
the last example, but leave the grouping choice to the student, as the row says.

## Fixer B: batch 2c, before its Codex read

Fix every Blocker and Major in `docs/content/verification/walkthrough-work/batch-2c-precheck-findings.md` and every scope
Major in `docs/content/verification/walkthrough-work/batch-2c-recompute-findings.md`, by pattern across each whole lesson.
Lead rulings:
- Prime test (Blocker): say which numbers it is for, for example "For a whole number from $6$ to $48$, it is prime if none
  of $2$, $3$ and $5$ divides it", and say that $2$, $3$ and $5$ are prime and $1$ is neither.
- A pair's Wrong line must show the cited wrong choice's mistake (digit-sums, cited choice 8). Do not change the citation.
- A Wrong line that reaches the right verdict shows no failure (last-digit): change it so it shows the mistake.
- Quiz-needed rules with no worked numbers (coprime, LCM joint events in a window, the sum of powers of $i$): add one short
  worked line or two under the rule, with numbers no quiz question uses, and stay at or under 900 words before a tap. If a
  lesson cannot fit it, list it for later in your report.
- Real number sets: scope "fractions are not whole numbers" (some fractions equal whole numbers, such as $\dfrac{6}{3}$),
  and say "square roots of non-negative integers".
Files: the 2c lessons those rows name, under `content/lessons/mathematics/arithmetic-number-sense/`. Do not edit the
`real-number-sets.md` code figure line or any SVG.

## Report (each, under 300 words)

Each row fixed how (one line); any changed check, try or pair with your re-solve; words after; the three checks' output.
