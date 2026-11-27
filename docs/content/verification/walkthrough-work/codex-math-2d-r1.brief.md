# Math batch 2d, Codex full read 1 of at most 2 (Codex GPT 6.2 Sol high, read-only)

Follow `codex-math-2c-r1.brief.md` in this folder in full (and the briefs it points to), with these changes:

- Target: the commit named in the run prompt; read target blobs by commit. Write findings to `batch-2d-r1.md` in your
  working directory, appending after each lesson. End with `BATCH VERDICT: PASS` (0 Blockers) or
  `BATCH VERDICT: FAIL (N Blockers, M Majors, K Minors)`, then `STAGE-DONE`.
- Twelve lessons, under `content/lessons/mathematics/arithmetic-number-sense/`: `arithmetic-sequence-terms.md`,
  `arithmetic-series-sums.md`, `geometric-sequence-terms.md`, `finite-geometric-series.md`, `infinite-geometric-series.md`,
  `harmonic-sequence-terms.md`, `fibonacci-type-sequence-terms.md`, `finding-number-patterns.md`,
  `odd-and-even-position-patterns.md`, `signed-integer-operations.md`, `substituting-negative-numbers.md`,
  `real-number-sets.md`. Audit every ILLUSTRATION picture in them (10), and the `real-number-sets.md` code figure's JSON.
- Real Number Sets was in batch 2c. Its 2c read 2 Blocker (the try could be answered by naming the false statement) and
  Major (rational and real used before they are defined) were fixed; check them. Its code-figure label overflow is with
  the UX lane; do not repeat it.
- Signed Integer Operations and Substituting Negative Numbers are parts 2 and 3 of a split of the live lesson
  `signed-integers-and-substitution.md` (Nov 25 approved samples). Audit them as lessons. The split's question-file and
  part-number changes are not in this read.
- Lead ruling for tries: the faded last step must be the step that applies the lesson's rule, not only the final
  arithmetic. Flag a try that hands over the rule move (Major).
- Lead's checks at the target (do not rerun): parser 12 of 12; main's `lesson_checks.dart` reports nothing for them;
  every lesson at or under 900 words before a tap; SVG preflight 0 failures. Blind pre-check (0 Blockers, 12 Majors, fixed)
  and recompute (0 mismatches): `batch-2d-precheck-findings.md`, `batch-2d-recompute-findings.md`.
