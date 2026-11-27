# Brief: Math batch 2b fixes after Codex read 1 (E-206)

Read `docs/content/verification/walkthrough-work/batch-2a-r1-fix-brief.md` in full first, and the briefs it names. All of
its rules, hard limits and checks apply (main's tools at the maintools path in `batch-2b-precheck-brief.md`). Lead's policy
commit `be4ec2f41`.

Findings: Codex read 1 of batch 2b, FAIL, 3 Blockers (1 lesson, 2 question files), 23 Majors, 14 Minors. The full file is
`/private/tmp/claude-501/-Users-aedwon--t3-worktrees-Pantas-content-lesson-walkthro-85719f9d9f054ca1/e9af84d4-e298-4015-a487-439b46cd24bf/scratchpad/codex/2b-r1/batch-2b-r1.md`
(read it there; a summary is in `codex-math-2b-r1.md` in this folder). Fix every lesson Blocker and Major row for your
lessons by pattern across the whole lesson. Each row gives its fix; use it unless it breaks a rule below. Minors: no change
unless on a line you already touch. Line numbers are at `0e8b93aa0`.

Not yours: the question-file Blockers (`order-of-operations.yaml` 0019, `word-problems.yaml` 0022) go to the release lead.

## Patterns

1. Over-broad rule (the lesson Blocker): "multiplying two fractions smaller than 1 gives a smaller answer" holds only when
   both are greater than 0 and less than 1. Say so. Check every "smaller", "larger", "always" claim in your lessons for the
   same gap (zero, negatives, a zero denominator, non-whole exponents).
2. Missing conditions: a positive whole-number exponent; "if the bottom is 0, the fraction is undefined"; "here $x$ is a
   positive length" beside the area picture; machines and clerks at the same steady rate; steady speed for $d=rt$; the same
   straight road; "if the amounts measure the same kind of thing" for same-unit ratios.
3. A rule with no worked numbers that a linked quiz question needs: add one short worked line or two under the rule, with
   numbers no quiz question uses (the rows name them: pie share comparison, a reservation before a ratio split, combining
   two subgroups' parts and totals, division order with $12\div4$ and $4\div12$, the whole-trip average speed with two legs,
   the late-start gap). Stay at or under 900 words before a tap.
4. Wrong or loose statements: the fraction bar location (grouping line 88); rounding before converting (fractions line 48:
   convert $\dfrac{8}{3}$ to a percent before rounding); the percent in a formula's numerator (averages line 65: write the
   share as a decimal).
5. Display lines: each line one move and ending at its value ($6-8=-2$, then $-2+4=2$; $16\div4=4$, then $4\times2=8$).
6. Lead-ins and labels: name each result as it appears (total, completed and remaining clerk-hours); say which terms are
   like terms before combining; say what the numbers in $180=60t$ are; connect the reciprocal check answer to "the two
   numbers multiply to $1$".

## Assignment (under `content/lessons/mathematics/`)

- Fixer A: `arithmetic-number-sense/adding-and-multiplying-fractions.md`, `fractions-and-mixed-forms.md`,
  `multiplying-and-dividing-decimals.md`, `operation-priority-and-left-to-right.md`, `grouping-and-fraction-bars.md`,
  `distribution-and-common-factors.md`, `commutative-and-associative-properties.md`, `additive-and-multiplicative-inverses.md`
  (all under `arithmetic-number-sense/`).
- Fixer B: `data-interpretation/averages-and-pie-chart-shares.md`, `data-interpretation/chart-scales-and-differences.md`,
  `data-interpretation/inverse-proportion-and-ratio-parts.md`, `data-interpretation/percentages-and-ratios-of-groups.md`,
  `algebra/motion-meeting-and-separation.md`.

Do not edit SVG files. Report as in the 2a fix brief, under 350 words.
