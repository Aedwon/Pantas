# Blind pre-check and recompute, Math batch 2c (E-206, step 3)

Read `docs/content/verification/walkthrough-work/batch-2b-precheck-brief.md` in full, and the briefs it points to. Its
rules, tool paths, picture checks, severities and formats apply here, with these changes. Lead's policy commit `be4ec2f41`.

Lessons (11), under `content/lessons/mathematics/arithmetic-number-sense/`: `coprime-divisibility-tests.md`,
`digit-sums-and-six.md`, `divisibility-by-seven-and-eleven.md`, `last-digit-divisibility.md`, `greatest-common-factor.md`,
`least-common-multiple.md`, `prime-factors-and-powers.md`, `same-remainder-numbers.md`, `real-number-sets.md`,
`complex-products-and-quotients.md`, `imaginary-unit-and-powers.md`. Pictures: every ILLUSTRATION marker in them, and the
code figure in `real-number-sets.md` (read its JSON as the picture).

What Codex found in batch 2b that the pre-check missed (look for these on purpose):
- A claim with "smaller", "larger", "always", "every" that fails for zero, negatives, or numbers outside the cases shown
  (Blocker when false). Divisibility tests: check that each test is stated for the numbers it works for.
- A rule that a linked quiz question needs but that has no worked numbers under it (Major).
- A display line that ends at a partial expression the next line repeats (Major).
- A loose statement of where something sits (a fraction bar, a digit place) or a rounded value converted again (Major).

Findings files: Worker 1 `docs/content/verification/walkthrough-work/batch-2c-precheck-findings.md`, Worker 2
`docs/content/verification/walkthrough-work/batch-2c-recompute-findings.md`.
