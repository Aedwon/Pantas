# Math batch 2b, Codex full read 1 of at most 2 (Codex GPT 6.2 Sol high, read-only)

Follow `codex-math-2a-r1.brief.md` in this folder in full (and the pilot brief it points to: startup, hard rules, format,
audit standard 1 to 5, severities, finding format, picture audit), with these changes:

- Target: the commit named in the run prompt; read target blobs by commit. Write findings to `batch-2b-r1.md` in your
  working directory, appending after each lesson. End with `BATCH VERDICT: PASS` (0 Blockers) or
  `BATCH VERDICT: FAIL (N Blockers, M Majors, K Minors)`, then `STAGE-DONE`.
- Thirteen lessons, under `content/lessons/mathematics/`: `arithmetic-number-sense/adding-and-multiplying-fractions.md`,
  `arithmetic-number-sense/fractions-and-mixed-forms.md`, `arithmetic-number-sense/multiplying-and-dividing-decimals.md`,
  `arithmetic-number-sense/operation-priority-and-left-to-right.md`, `arithmetic-number-sense/grouping-and-fraction-bars.md`,
  `arithmetic-number-sense/distribution-and-common-factors.md`, `arithmetic-number-sense/commutative-and-associative-properties.md`,
  `arithmetic-number-sense/additive-and-multiplicative-inverses.md`, `data-interpretation/averages-and-pie-chart-shares.md`,
  `data-interpretation/chart-scales-and-differences.md`, `data-interpretation/inverse-proportion-and-ratio-parts.md`,
  `data-interpretation/percentages-and-ratios-of-groups.md`, `algebra/motion-meeting-and-separation.md`.
- No pilot pictures in this read. Audit every ILLUSTRATION picture in these 13 lessons.
- Motion Meeting and Separation was in batch 2a. Its batch 2a read 2 Blockers (`codex-math-2a-r2.md` in this folder: the
  add-speeds rule for a late start and for moving the same direction) were fixed; check them.
- Lead rulings carried from batch 2a: double-dollar display math stays (do not flag fences); "for later" quiz skills are
  Minors; a pair may show the cited mistake with other numbers. A display line must end at a value, so a line such as
  "$25-9i^2=25+9=34$" is how the checks require a two-step simplification to end; flag it only if a student cannot follow it.
- Lead's checks at the target (do not rerun): parser 13 of 13; main's `lesson_checks.dart` (`8ed6a0b4f`) reports nothing
  for them; every lesson at or under 900 words before a tap; SVG preflight 0 failures. Blind pre-check (0 Blockers; 6
  Majors fixed) and recompute (0 mismatches): `batch-2b-precheck-findings.md`, `batch-2b-recompute-findings.md`.
