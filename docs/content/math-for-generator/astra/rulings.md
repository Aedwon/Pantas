# CET math audit: lead rulings

November 16, 2026 (UTC). Astra (gpt-6-astra, high, read-only) audited 22 units: the 11 CET-rewritten math lessons outside Algebra that had no audit, and the 49 live Algebra parts in their 11 families, with the CET rewrite of 5 parents as a reference. Results: `results/`.

32 findings: 6 Blocker, 26 Major, in 7 of 11 Algebra families and 3 of 11 lessons. No flagged part is a CSE lesson; all are CET-only (live on prod but hidden while CET exams are "Coming soon"). The other 8 lessons and 4 families had none.

## Rulings

All 32 upheld. Fix the smallest way that removes the error:

- **False general statements (6 Blockers):** add the condition, do not rewrite.
  - simplifying-and-evaluating-expressions: the exponent definition holds for positive whole-number exponents; say so.
  - rationalizing-square-root-denominators: use the conjugate when it is not zero.
  - systems-substitution-and-word-problems: remove the claim that test-makers "always" put the plain x value in the choices; say a choice may show it.
  - basic-geometric-concepts: vertical angles are one case where expressions are equal; drop "only".
  - circles: a triple, or a multiple of one (including a scaled one such as 1.5, 2, 2.5), helps; drop "only when all three sides are whole numbers".
  - The sixth Blocker is the exponent one above, counted with the algebraic-expressions family.
- **Figure markers that show an answer before the solution (13):** move the marker, unchanged, to just after that example's worked solution, as was done on November 10. Applies to one-variable-inequalities (2), line-slopes-and-intercepts (1), counting-venn-diagram-regions (2), circles (3), coordinate-geometry (5).
- **A needed method or symbol never taught in that part (13):** add one or two plain sentences that teach it, or one sentence that names the part that teaches it ("Part N, <title>, shows how to ..."), whichever is shorter. Applies to rates-and-consecutive-integers, fractional-powers-and-exponent-equations (2), functions-domain-and-range, line-slopes-and-intercepts (perpendicular), parallel-and-perpendicular-lines, two-variable-inequalities, factoring-quadratic-equations, simplifying-and-combining-radicals, cube-root-denominators-and-nested-radicals, set-membership-and-operations, counting-venn-diagram-regions (|A|), systems-lines-and-parabolas, rational-slant-asymptotes.

## Gaps (not findings)

The 5 rewritten parents list 35 CET-level skills the parts do not teach (`gaps` in the result files). They are not errors, and adding them is new writing, which the brief does not cover. Listed for the manager.

## Fix and check

Fix: Codex GPT 6.1 Sol, medium, one job (`fix-brief.md`). Check: a fresh Astra read of every changed file against its finding.
