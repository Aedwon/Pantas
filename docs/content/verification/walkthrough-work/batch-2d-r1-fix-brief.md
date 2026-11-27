# Brief: Math batch 2d fixes after Codex read 1 (E-206)

Read `docs/content/verification/walkthrough-work/batch-2c-r1-fix-brief.md` in full first, and the briefs it names. All of
its rules, rulings, hard limits and checks apply. Lead's policy commit `be4ec2f41`.

Findings: Codex read 1 of batch 2d, FAIL (4 Blockers, 9 Majors, 11 Minors), full file at
`/private/tmp/claude-501/-Users-aedwon--t3-worktrees-Pantas-content-lesson-walkthro-85719f9d9f054ca1/e9af84d4-e298-4015-a487-439b46cd24bf/scratchpad/codex/2d-r1/batch-2d-r1.md`.
Fix every Blocker and Major row for your lessons by pattern across each whole lesson, using each row's fix unless it breaks
a rule. Minors: no change unless on a line you touch. Line numbers are at `6a5213882`.

Lead rulings:
- Over-broad rules (Blockers): say exactly when the rule holds ("terms with the same variable raised to the same power";
  "the flipped form makes $r^n-1$ and $r-1$ positive; the sign of the sum also depends on $a_1$"). Check every rule in your
  lessons for the same gap.
- A Quick Check with two valid patterns (finding-number-patterns): state the pattern's type in the stem, as the row says,
  so only one answer fits. Re-solve; key not printed above or in its stem.
- Checklist lines must hold in every case they name (odd/even: continue the group that matches the next position).
- Tries that hand over the rule move (arithmetic-series, fibonacci, substituting): the visible steps stop before the rule
  move, and the try asks for it. Keep the try the faded last step.
- `real-number-sets.md`: introduce "real number" before the irrational definition uses it. Keep the code figure line.
- Picture text: the SVG title in
  `content/illustrations/mathematics/arithmetic-number-sense/infinite-geometric-series/01-bar-of-length-2-halving-gap.svg`
  must say "The filled length approaches 2 as the dashed gap shrinks to 0." Change only that text (Fixer B).

## Assignment (under `content/lessons/mathematics/arithmetic-number-sense/`)

- Fixer A: `finite-geometric-series.md`, `fibonacci-type-sequence-terms.md`, `finding-number-patterns.md`,
  `odd-and-even-position-patterns.md`, `geometric-sequence-terms.md`.
- Fixer B: `arithmetic-series-sums.md`, `substituting-negative-numbers.md`, `real-number-sets.md`, and the SVG title above
  (Edit tool; then run the SVG validator, `--validate-only`).

Report each row fixed how (one line), any changed check or try with your re-solve, words after, and the checks' output,
under 300 words.
