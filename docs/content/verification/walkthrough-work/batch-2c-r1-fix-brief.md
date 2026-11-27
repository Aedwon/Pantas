# Brief: Math batch 2c fixes after Codex read 1 (E-206)

Read `docs/content/verification/walkthrough-work/batch-2b-r1-fix-brief.md` in full first, and the briefs it names. All of
its rules, patterns, hard limits and checks apply. Lead's policy commit `be4ec2f41`.

Findings: Codex read 1 of batch 2c, FAIL (4 Blockers, 11 Majors, 11 Minors), full file at
`/private/tmp/claude-501/-Users-aedwon--t3-worktrees-Pantas-content-lesson-walkthro-85719f9d9f054ca1/e9af84d4-e298-4015-a487-439b46cd24bf/scratchpad/codex/2c-r1/batch-2c-r1.md`.
Fix every Blocker and Major row for your lessons, by pattern across the whole lesson, using each row's fix unless it breaks
a rule. Minors: no change unless on a line you touch. Line numbers are at `e48944521`.

Lead rulings:
- Number words: "integer" for any whole number that can be negative; "whole number" only for $0, 1, 2, \dots$. Check every
  use in your lessons.
- A set classification names every set a number belongs to ("$-4$ is an integer, a rational number and a real number. It
  is not a natural or whole number.").
- A try or check whose answer can be found by matching visible text (real-number-sets try): change what it asks so the
  student must compute the step the lesson teaches, as the row says.
- Wrong lines show only the cited mistake, with numbers where the wrong and right methods give different verdicts.
- The real-number-sets code figure label overflow (Major, line 43) is app drawing code, not lesson text. Do not change the
  figure line. The lead sends it to the manager for the UX lane.
- Picture placement: move a marker line unchanged so it sits right after the text whose numbers it shows (LCM).

## Assignment (under `content/lessons/mathematics/arithmetic-number-sense/`)

- Fixer A: `coprime-divisibility-tests.md`, `digit-sums-and-six.md`, `divisibility-by-seven-and-eleven.md`,
  `last-digit-divisibility.md`, `greatest-common-factor.md`.
- Fixer B: `least-common-multiple.md`, `prime-factors-and-powers.md`, `real-number-sets.md`,
  `complex-products-and-quotients.md`, `imaginary-unit-and-powers.md`.

Do not edit SVG files. Report each row fixed how (one line), any changed check or try with your re-solve, words after, and
the three checks' output, under 300 words.
