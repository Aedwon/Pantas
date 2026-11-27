# Math batch 2c, Codex full read 1 of at most 2 (Codex GPT 6.2 Sol high, read-only)

Follow `codex-math-2b-r1.brief.md` in this folder in full (and the briefs it points to), with these changes:

- Target: the commit named in the run prompt; read target blobs by commit. Write findings to `batch-2c-r1.md` in your
  working directory, appending after each lesson. End with `BATCH VERDICT: PASS` (0 Blockers) or
  `BATCH VERDICT: FAIL (N Blockers, M Majors, K Minors)`, then `STAGE-DONE`.
- Eleven lessons, under `content/lessons/mathematics/arithmetic-number-sense/`: `coprime-divisibility-tests.md`,
  `digit-sums-and-six.md`, `divisibility-by-seven-and-eleven.md`, `last-digit-divisibility.md`, `greatest-common-factor.md`,
  `least-common-multiple.md`, `prime-factors-and-powers.md`, `same-remainder-numbers.md`, `real-number-sets.md`,
  `complex-products-and-quotients.md`, `imaginary-unit-and-powers.md`. Audit every ILLUSTRATION picture in them, and the
  `<!-- FIGURE: {...} -->` code figure in `real-number-sets.md` (read its JSON as the picture; the app draws it).
- Not in scope: the motion and 2b lesson notes in the 2b brief. Lead's checks at the target (do not rerun): parser 11 of
  11; main's `lesson_checks.dart` reports nothing for them; every lesson at or under 900 words before a tap; SVG preflight
  0 failures. Blind pre-check (1 Blocker, 11 Majors, all fixed) and recompute (0 mismatches, 8 scope Majors, fixed):
  `batch-2c-precheck-findings.md`, `batch-2c-recompute-findings.md`.
